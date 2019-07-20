#include <SC_PlugIn.h>
#include <stdio.h>

int main() {
  printf("size: %lu\n", sizeof(int));
  printf("size of InterfaceTable: %lu\n", sizeof(InterfaceTable));
  InterfaceTable* ptr = (InterfaceTable*) malloc(sizeof(InterfaceTable));
  void* fDefineUnit_ptr = &ptr->fDefineUnit;
  printf("table ptr: %p, fDefineUnit ptr: %p\n", ptr, fDefineUnit_ptr);
  printf("diff: %d\n", (long int) fDefineUnit_ptr - (long int) ptr);
  return 0;
}
