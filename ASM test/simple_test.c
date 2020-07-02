#include <stdio.h>
#include <stdlib.h>

int test_MULHU ( int i0, int i1 ){
   int ret;
   asm volatile ("mulhu %0, %1, %2" : "=r"(ret) : "r"(i0), "r"(i1));
   return ret;
}

int test_MUL ( int i0, int i1 ){
   int ret;
   asm volatile ("mul %0, %1, %2" : "=r"(ret) : "r"(i0), "r"(i1));
   return ret;
}

int test_MULH ( int i0, int i1 ){
   int ret;
   asm volatile ("mulh %0, %1, %2" : "=r"(ret) : "r"(i0), "r"(i1));
   return ret;
}

int test_MULHSU ( int i0, int i1 ){
   int ret;
   asm volatile ("mulhsu %0, %1, %2" : "=r"(ret) : "r"(i0), "r"(i1));
   return ret;
}

int test_DIV ( int i0, int i1 ){
   int ret;
   asm volatile ("div %0, %1, %2" : "=r"(ret) : "r"(i0), "r"(i1));
   return ret;
}

int test_DIVU ( int i0, int i1 ){
   int ret;
   asm volatile ("divu %0, %1, %2" : "=r"(ret) : "r"(i0), "r"(i1));
   return ret;
}

int test_REM ( int i0, int i1 ){
   int ret;
   asm volatile ("rem %0, %1, %2" : "=r"(ret) : "r"(i0), "r"(i1));
   return ret;
}

int test_REMU ( int i0, int i1 ){
   int ret;
   asm volatile ("remu %0, %1, %2" : "=r"(ret) : "r"(i0), "r"(i1));
   return ret;
}

int main(int argc, char** argv){
   int i0, i1, cnt, result;

   if( argc == 1 ){

      printf ( "\n\n" );
      printf( "Number 1: \n" );
      scanf( "%d", &i0 );

      printf( "Number 2: \n" );
      scanf( "%d", &i1 );

      printf( "Times: \n" );
      scanf( "%d", &cnt );
   }else if (argc == 4){
      i0 = atoi(argv[1]);
      i1 = atoi(argv[2]);
      cnt = atoi(argv[3]);
   }else{
      printf ("USAGE: argc is 1 or 4\n" );
      printf ("ALL MUST be within i32\n\n" );
      return 1;
   }

   printf( "\n\n" );

   for( int i = 0; i < cnt; ++i ){
      result = test_MUL( i0, i1+i );
      printf( "%d   MUL    %d is %d\n",   i0, i1+i, result );
      result = test_MULH( i0, i1+i );
      printf( "%d   MULH   %d is %d\n",   i0, i1+i, result );
      result = test_MULHSU( i0, i1+i );
      printf( "%d   MULHSU %d is %d\n",   i0, i1+i, result );
      result = test_MULHU( i0, i1+i );
      printf( "%d   MULHU  %d is %d\n",   i0, i1+i, result );
      result = test_DIV( i0, i1+i );
      printf( "%d   DIV    %d is %d\n",   i0, i1+i, result );
      result = test_DIVU( i0, i1+i );
      printf( "%d   DIVU   %d is %d\n",   i0, i1+i, result );
      result = test_REM( i0, i1+i );
      printf( "%d   REM    %d is %d\n",   i0, i1+i, result );
      result = test_REMU( i0, i1+i );
      printf( "%d   REMU   %d is %d\n\n", i0, i1+i, result );
   }

   return 0;
}
