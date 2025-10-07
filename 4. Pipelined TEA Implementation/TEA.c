#include <stdio.h>
#include <stdint.h>

void encrypt(uint32_t v[2], const uint32_t k[4]) {
    uint32_t v0 = v[0], v1 = v[1], sum = 0, i;           /* set up */
    uint32_t delta = 0x9E3779B9;                         /* a key schedule constant */
    uint32_t k0 = k[0], k1 = k[1], k2 = k[2], k3 = k[3]; /* cache key */
    // printf("#%08x, v0 (init): %08x, v1 (init): %08x, sum (init): %08x\n", i, v0, v1, sum);
    for (i = 0; i < 32; i++) {                           /* basic cycle start */
        sum += delta;
        v0 += ((v1 << 4) + k0) ^ (v1 + sum) ^ ((v1 >> 5) + k1);
        v1 += ((v0 << 4) + k2) ^ (v0 + sum) ^ ((v0 >> 5) + k3);
        // printf("#%08x, v0: %08x, v1: %08x, sum: %08x\n", i, v0, v1, sum);
    }                                                   /* end cycle */
    v[0] = v0;
    v[1] = v1;
}

int main() {
    uint32_t plaintext[2] = {0x11223344, 0x55667788}; /* Plaintext */
    uint32_t key[4] = {0x11111111, 0x22222222, 0x33333333, 0x44444444}; /* Key */
    printf("Test case 1:\n");
    printf("Original plaintext: v0: %08x, v1: %08x\n", plaintext[0], plaintext[1]);
    encrypt(plaintext, key);
    printf("Encrypted ciphertext: v0: %08x, v1: %08x\n\n", plaintext[0], plaintext[1]);
    // 0001001001101100011010111001001011000000011001010011101000111110
    // 0001001001101100011010111001001011000000011001010011101000111110

    printf("\n/////////////////////////////////////////\n\n");

    plaintext[0] = 0xdeadbeef;
    plaintext[1] = 0xfeedface;
    key[0] = 0x11223344;
    key[1] = 0x55667788;
    key[2] = 0x99aabbcc;
    key[3] = 0xddeeff00;
    printf("Test case 2:\n");
    printf("Original plaintext: v0: %08x, v1: %08x\n", plaintext[0], plaintext[1]);
    encrypt(plaintext, key);
    printf("Encrypted ciphertext: v0: %08x, v1: %08x\n\n", plaintext[0], plaintext[1]);
    // 0001110100011001101001001110011000111010001011100110111000101001
    // 0001110100011001101001001110011000111010001011100110111000101001
    1010001000101000101101111111110011001010010111100000111111010101
    101000111001110001000111101010101011111001011011000101001010011
    printf("\n/////////////////////////////////////////\n\n");

    // plaintext[0] = 0xabcdef01;
    // plaintext[1] = 0x12345678;
    // key[0] = 0x00001111;
    // key[1] = 0x22223333;
    // key[2] = 0x44445555;
    // key[3] = 0x66667777;
    // printf("Test case 3:\n");
    // printf("Original plaintext: v0: %08x, v1: %08x\n", plaintext[0], plaintext[1]);
    // encrypt(plaintext, key);
    // printf("Encrypted ciphertext: v0: %08x, v1: %08x\n\n", plaintext[0], plaintext[1]);

    // printf("\n/////////////////////////////////////////\n\n");

    // plaintext[0] = 0xcafebabe;
    // plaintext[1] = 0xdeadbeef;
    // key[0] = 0x88889999;
    // key[1] = 0xaaaa5555;
    // key[2] = 0x3333cccc;
    // key[3] = 0x99998888;
    // printf("Test case 4:\n");
    // printf("Original plaintext: v0: %08x, v1: %08x\n", plaintext[0], plaintext[1]);
    // encrypt(plaintext, key);
    // printf("Encrypted ciphertext: v0: %08x, v1: %08x\n\n", plaintext[0], plaintext[1]);

    // printf("\n/////////////////////////////////////////\n\n");

    // plaintext[0] = 0x11111111;
    // plaintext[1] = 0x22222222;
    // key[0] = 0x33333333;
    // key[1] = 0x44444444;
    // key[2] = 0x55555555;
    // key[3] = 0x66666666;
    // printf("Test case 5:\n");
    // printf("Original plaintext: v0: %08x, v1: %08x\n", plaintext[0], plaintext[1]);
    // encrypt(plaintext, key);
    // printf("Encrypted ciphertext: v0: %08x, v1: %08x\n\n", plaintext[0], plaintext[1]);

    // printf("\n/////////////////////////////////////////\n\n");

    // plaintext[0] = 0x77777777;
    // plaintext[1] = 0x88888888;
    // key[0] = 0x99999999;
    // key[1] = 0xaaaaaaaa;
    // key[2] = 0xbbbbbbbb;
    // key[3] = 0xcccccccc;
    // printf("Test case 6:\n");
    // printf("Original plaintext: v0: %08x, v1: %08x\n", plaintext[0], plaintext[1]);
    // encrypt(plaintext, key);
    // printf("Encrypted ciphertext: v0: %08x, v1: %08x\n\n", plaintext[0], plaintext[1]);

    // printf("\n/////////////////////////////////////////\n\n");

    // plaintext[0] = 0xffffffff;
    // plaintext[1] = 0x00000000;
    // key[0] = 0x12345678;
    // key[1] = 0x87654321;
    // key[2] = 0xaaaaaaaa;
    // key[3] = 0x55555555;
    // printf("Test case 7:\n");
    // printf("Original plaintext: v0: %08x, v1: %08x\n", plaintext[0], plaintext[1]);
    // encrypt(plaintext, key);
    // printf("Encrypted ciphertext: v0: %08x, v1: %08x\n\n", plaintext[0], plaintext[1]);

    return 0;
}
