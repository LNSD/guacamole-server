/* Static linker script for symbol redirection and overrides */
/* This file demonstrates how to redirect function symbols to custom implementations */

/* Example: Override libguac's memory allocation functions */
/* EXTERN(__guac_core__PRIV_guac_mem_alloc); */
/* EXTERN(__guac_core__PRIV_guac_mem_zalloc); */
/* EXTERN(__guac_core__PRIV_guac_mem_realloc); */
/* EXTERN(__guac_core__PRIV_guac_mem_free); */

/* PRIV_guac_mem_alloc   = __guac_core__PRIV_guac_mem_alloc; */
/* PRIV_guac_mem_zalloc  = __guac_core__PRIV_guac_mem_zalloc; */
/* PRIV_guac_mem_realloc = __guac_core__PRIV_guac_mem_realloc; */
/* PRIV_guac_mem_free    = __guac_core__PRIV_guac_mem_free; */

