import pandas as pd

class QuickSorter(object):
    STATUS_NONE = "none"
    STATUS_SORTING = "sorting"
    STATUS_PIVOT = "pivot"

    def __init__(self, data):
        self._data = data
        self._snapshots = []
        self._sorted = False
        for idx, value in enumerate(self._data):
            self._snapshots.append(
                {
                    "position": idx,
                    "value": value,
                    "iteration": 0,
                    "status": QuickSorter.STATUS_NONE,
                    "pivot": 0
                }
            )
        self._iteration_count = 1

    @property
    def data(self):
        return self._data

    @data.setter
    def data(self, new_data):
        """
        Ensures a "sorted" state is invalidated on data change.
        """
        self._data = new_data
        self.sorted = False

    @property
    def snapshots(self):
        return pd.DataFrame.from_records(self._snapshots)

    def quick_sort(self, low_idx, high_idx):
        if low_idx < high_idx:
            _, pivot_idx = self.partition(low_idx, high_idx)
            self._snapshot(low_idx, high_idx, pivot_idx)
            self.quick_sort(low_idx, pivot_idx - 1)
            self.quick_sort(pivot_idx + 1, high_idx)

    def partition(self, low_idx, high_idx):
        i = low_idx - 1
        pivot = self.data[high_idx]
        for j in range(low_idx, high_idx):
            if self.data[j] <= pivot:
                i += 1
                swap(self.data, i, j)
        swap(self.data, i + 1, high_idx)
        pivot_idx = i + 1
        return self.data, pivot_idx

    def _snapshot(self, low_idx, high_idx, pivot_idx):
        """
        Copy self.data, indicating if each element is currently being sorted.
        """
        for idx, value in enumerate(self._data):
            self._snapshots.append(
                {
                    "position": idx,
                    "value": value,
                    "iteration": self._iteration_count,
                    "status": QuickSorter.STATUS_PIVOT
                    if idx == pivot_idx
                    else QuickSorter.STATUS_SORTING
                    if idx in range(low_idx, high_idx + 1)
                    else QuickSorter.STATUS_NONE,
                    "pivot": self.data[pivot_idx]
                }
            )
        self._iteration_count += 1

def quick_sort(array, low_idx, high_idx):
    """
    Sort an array using the quick sort algorithm.

    >>> quick_sort([6, 7, 13, 1, 12, 8, 14, 2], 0, 7)
    [1, 2, 6, 7, 8, 12, 13, 14]
    """
    if low_idx < high_idx:
        _, pivot_idx = partition(array, low_idx, high_idx)
        quick_sort(array, low_idx, pivot_idx - 1)
        quick_sort(array, pivot_idx + 1, high_idx)
    return array


def swap(array, first_idx, second_idx):
    """
    Swap two elements in an array.

    >>> swap([13, 31], 0, 1)
    [31, 13]
    """
    array[first_idx], array[second_idx] = array[second_idx], array[first_idx]
    return array

def partition(array, low_idx, high_idx):
    """
    Partition array into arrays of items smaller and larger than pivot.

    >>> partition([2, 8, 7, 1, 3, 5, 6, 4], 0, 7)
    ([2, 1, 3, 4, 7, 5, 6, 8], 3)
    """
    i = low_idx - 1
    pivot = array[high_idx]
    for j in range(low_idx, high_idx):
        if array[j] <= pivot:
            i += 1
            swap(array, i, j)
    swap(array, i + 1, high_idx)
    pivot_idx = i + 1
    return array, pivot_idx
