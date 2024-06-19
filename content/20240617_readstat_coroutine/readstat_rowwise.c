/* [[file:../20240617_readstat_coroutine.org::*Headers and a Context Object][Headers and a Context Object:1]] */
#include <readstat.h>

#define MINICORO_IMPL
#include "../minicoro/minicoro.h"

typedef struct {
  int col_count;
  mco_coro *co;
} rs_ctx;
/* Headers and a Context Object:1 ends here */

/* [[file:../20240617_readstat_coroutine.org::*Metadata Handler][Metadata Handler:1]] */
int handle_metadata(readstat_metadata_t *metadata, void *ctx) {
  rs_ctx *my_count = (rs_ctx *)ctx;
  /* `var_count` corresponds to column count */
  my_count->col_count = readstat_get_var_count(metadata);

  return READSTAT_HANDLER_OK;
}
/* Metadata Handler:1 ends here */

/* [[file:../20240617_readstat_coroutine.org::*Variable Handler][Variable Handler:1]] */
int handle_variable(int index, readstat_variable_t *variable,
			  const char *val_labels, void *ctx) {
  /* this loops through column names to print the first line */
  rs_ctx *meta = (rs_ctx *)ctx;
  printf("%s", readstat_variable_get_name(variable));
  if (index == meta->col_count - 1) {
    printf("\n");
  } else {
    printf("\t");
  }
  return READSTAT_HANDLER_OK;
}
/* Variable Handler:1 ends here */

/* [[file:../20240617_readstat_coroutine.org::*Value Handler][Value Handler:1]] */
int handle_value(int obs_index, readstat_variable_t *variable,
		       readstat_value_t value, void *ctx) {
   /* this loops through the rest of the rows to print values */
   rs_ctx *meta = (rs_ctx *)ctx;
   int var_index = readstat_variable_get_index(variable);
   readstat_type_t type = readstat_value_type(value);
   if (!readstat_value_is_system_missing(value)) {
     if (type == READSTAT_TYPE_STRING) {
	    printf("%s", readstat_string_value(value));
     } else if (type == READSTAT_TYPE_INT8) {
	    printf("%.2hhd", readstat_int8_value(value));
     } else if (type == READSTAT_TYPE_INT16) {
	    printf("%.2hd", readstat_int16_value(value));
     } else if (type == READSTAT_TYPE_INT32) {
	    printf("%.2d", readstat_int32_value(value));
     } else if (type == READSTAT_TYPE_FLOAT) {
	    printf("%.2f", readstat_float_value(value));
     } else if (type == READSTAT_TYPE_DOUBLE) {
	    printf("%.2lf", readstat_double_value(value));
     }
   }

   if (var_index == meta->col_count - 1) {
     printf("\n");
     mco_resume(meta->co);
   } else {
     printf("\t");
   }
   return READSTAT_HANDLER_OK;
 }
/* Value Handler:1 ends here */

/* [[file:../20240617_readstat_coroutine.org::*Coroutine Entry Function][Coroutine Entry Function:1]] */
void coro_entry(mco_coro *co) {
  int current_row_count = 1;
  // stop after initializing state
  mco_yield(co);

  while (1) {
    printf("finished reading row #: %d\n", current_row_count++);
    mco_yield(co);
  }
}
/* Coroutine Entry Function:1 ends here */

/* [[file:../20240617_readstat_coroutine.org::*Main][Main:1]] */
int main(int argc, char *argv[]) {
  if (argc != 2) {
    printf("Usage: %s <filename>\n", argv[0]);
    return 1;
  }

  // setup the coroutine object
  mco_desc desc = mco_desc_init(coro_entry, 0);
  desc.user_data = NULL;
  mco_coro *co;
  mco_result res = mco_create(&co, &desc);
  res = mco_resume(co);

  // initialize ReadStat's context
  rs_ctx meta = {.col_count = 0, .co = co};
  readstat_error_t error = READSTAT_OK;
  readstat_parser_t *parser = readstat_parser_init();

  // set the handlers
  readstat_set_metadata_handler(parser, &handle_metadata);
  readstat_set_variable_handler(parser, &handle_variable);
  readstat_set_value_handler(parser, &handle_value);

  error = readstat_parse_sas7bdat(parser, argv[1], &meta);
  res = mco_destroy(co);
  readstat_parser_free(parser);

  if (error != READSTAT_OK) {
    printf("Error processing %s: %d\n", argv[1], error);
    return 1;
  }
  return 0;
}
/* Main:1 ends here */
