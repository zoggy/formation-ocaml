#define testmode [%getenv "TESTMODE"]

#ifdef testmode
  print_endline "test mode on"
#elif testmode
  print_endline "test mode off"
#endif
;;
