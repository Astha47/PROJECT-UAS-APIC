import numpy as np

def systolic_array_matmul(A, B):
    """
    Simulates an NxN systolic array for matrix multiplication.
    A and B must be square matrices of the same size.
    """
    N = A.shape[0]
    C = np.zeros((N, N), dtype=int)

    # Simulate the systolic array data movement and accumulation
    for t in range(2 * N - 1):  # Time steps
        for i in range(N):
            for j in range(N):
                if 0 <= t - i < N and 0 <= t - j < N:
                    C[i][j] += A[i][t - j] * B[t - i][j]
    return C

# Generate random 8x8 input matrices
np.random.seed(0)
A = np.random.randint(0, 10, (8, 8))
B = np.random.randint(0, 10, (8, 8))

# Perform matrix multiplication using systolic array simulation
C = systolic_array_matmul(A, B)

# Print results
print("Matrix A:\n", A)
print("Matrix B:\n", B)
print("Result Matrix C = A × B:\n", C)
