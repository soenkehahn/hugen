#include <SC_PlugIn.h>
#include <stdio.h>

int main() {
  printf("size of int: %lu\n", sizeof(int));
  printf("size of InterfaceTable: %lu\n", sizeof(InterfaceTable));
  InterfaceTable* ptr = (InterfaceTable*) malloc(sizeof(InterfaceTable));
  void* field_ptr = &ptr->fDefineBufGen;
  printf("table ptr: %p, field ptr: %p\n", ptr, field_ptr);
  printf("offset: %li\n", (long int) field_ptr - (long int) ptr);
  return 0;
}
