.data
N:  .word 8                  # int N = 8;

A:  .word 5, 2, 9, 1, 3, 7, 0, 4   # int A[N] = {5,2,9,1,3,7,0,4};
T:  .space 32                # int T[N]; 


.text
.globl main

main:
    lasw   s0, A               # int *Aptr = A;
    lasw   s1, T               # int *Tptr = T;
    #lw   s2, N               # int N_val = N;
    addi s2, x0, 8

    li   s3, 1               # width = 1;

outer_width_loop:
nop
nop
    bge  s3, s2, main_done   # if (width >= N) break;

    li   s4, 0               # i = 0;

inner_i_loop:
nop
nop
    bge  s4, s2, after_inner # if (i >= N) break;


    mv   t0, s4              # left = i;

    add  t1, s4, s3          # mid = i + width;
    nop
    nop
    blt  t1, s2, mid_ok      # if (mid < N) keep mid;
    mv   t1, s2              # else mid = N;
mid_ok:

    slli s5, s3, 1           # twoW = 2 * width;
    nop
    nop
    add  t3, s4, s5          # right = i + twoW;
    nop
    nop
    blt  t3, s2, right_ok    # if (right < N) keep right;
    mv   t3, s2              # else right = N;
right_ok:

    mv   a0, s0              # a0 = A;
    mv   a1, s1              # a1 = T;
    mv   a2, t0              # a2 = left;
    mv   a3, t1              # a3 = mid;
    mv   a4, t3              # a4 = right;
    jal  ra, merge           # merge(A, T, left, mid, right);

    add  s4, s4, s5          # i = i + 2 * width;
    j    inner_i_loop        # next i

after_inner:
    slli s3, s3, 1           # width = 2 * width;
    j    outer_width_loop    # next width

main_done:
    addi   a7, x0, 10              # syscall 10 = exit
    
    ecall                    # return 0;
    wfi

    nop


# merge(int *A, int *T, int left, int mid, int right)
# a0 = A, a1 = T, a2 = left, a3 = mid, a4 = right
merge:
    mv   t0, a2              # int i = left;
    mv   t1, a3              # int j = mid;
    mv   t2, a2              # int k = left;

merge_main_loop:
    bge  t0, a3, merge_after_main   # if (i >= mid) break;
    bge  t1, a4, merge_after_main   # if (j >= right) break;

    slli t3, t0, 2           # tmp = i * 4; #OPTIMIZE SO BOTH i AND j ARE UPDATED IN TANDEM, LESS NOPS
    nop
    nop
    add  t3, a0, t3          # &A[i];
    nop
    nop
    lw   t5, 0(t3)           # Ai = A[i];

    slli t4, t1, 2           # tmp = j * 4;
    nop
    nop
    add  t4, a0, t4          # &A[j];
    nop
    nop
    lw   t6, 0(t4)           # Aj = A[j];
    nop
    nop

    ble  t5, t6, merge_take_left    # if (Ai <= Aj) take left;

    slli t3, t2, 2           # tmp = k * 4;
    nop
    nop
    add  t3, a1, t3          # &T[k];
    nop
    nop
    sw   t6, 0(t3)           # T[k] = Aj;
    addi t1, t1, 1           # j++;
    addi t2, t2, 1           # k++;
    j    merge_main_loop     # continue while;

merge_take_left:
    slli t3, t2, 2           # tmp = k * 4;
    nop
    nop
    add  t3, a1, t3          # &T[k];
    nop
    nop
    sw   t5, 0(t3)           # T[k] = Ai;
    addi t0, t0, 1           # i++;
    addi t2, t2, 1           # k++;
    j    merge_main_loop     # continue while;

merge_after_main:
merge_left_loop:
    bge  t0, a3, merge_right_loop   # if (i >= mid) break;

    slli t3, t0, 2           # tmp = i * 4; #ANOTHER OPTIMIZATION BETWEEN i and k
    nop
    nop
    add  t3, a0, t3          # &A[i];
    nop
    nop
    lw   t5, 0(t3)           # val = A[i];

    slli t4, t2, 2           # tmp = k * 4;
    nop
    nop
    add  t4, a1, t4          # &T[k];
    nop
    nop
    sw   t5, 0(t4)           # T[k] = val;

    addi t0, t0, 1           # i++;
    addi t2, t2, 1           # k++;
    j    merge_left_loop     # loop;

merge_right_loop:
    bge  t1, a4, merge_copy_back    # if (j >= right) break;

    slli t3, t1, 2           # tmp = j * 4; #OPTIMIZE
    nop
    nop
    add  t3, a0, t3          # &A[j];
    nop
    nop
    lw   t6, 0(t3)           # val = A[j];

    slli t4, t2, 2           # tmp = k * 4;
    nop
    nop
    add  t4, a1, t4          # &T[k];
    nop
    nop
    sw   t6, 0(t4)           # T[k] = val;

    addi t1, t1, 1           # j++;
    addi t2, t2, 1           # k++;
    j    merge_right_loop    # loop;

merge_copy_back:
    mv   t0, a2              # int idx = left;

merge_copy_loop:
nop
nop
    bge  t0, a4, merge_ret   # if (idx >= right) break;

    slli t3, t0, 2           # tmp = idx * 4; #OPTIMIZE
    nop
    nop
    add  t3, a1, t3          # &T[idx];
    nop
    nop
    lw   t5, 0(t3)           # val = T[idx];

    slli t4, t0, 2           # tmp = idx * 4;
    nop
    nop
    add  t4, a0, t4          # &A[idx];
    nop
    nop
    sw   t5, 0(t4)           # A[idx] = val;

    addi t0, t0, 1           # idx++;
    j    merge_copy_loop     # loop;

merge_ret:
    jr   ra                  # return;
