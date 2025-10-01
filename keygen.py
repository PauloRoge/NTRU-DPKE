import random
n = 509 # 1.3.2 
q = 2048 #potência de dois
p=3

#A polynomial is ternary if its coefficients are in {−1, 0, 1}.
#R = PolynomialRing(ZZ, 'x') #define anel de polinômios com coeficientes inteiros
#x = R.gen()
R.<x> = ZZ[]
Phi_n = (x^n-1)//(x-1) 
S.<y> = R.quotient(Phi_n)    

def sample_fg(n,q):
    d = q//8-2
    coeficiente = [random.choice([-1, 0, 1]) for i in range(n-1)]
    while sum(abs(c) for c in coeficiente)==0:
    coeficiente = [random.choice([-1, 0, 1]) for i in range(n-1)]
    
    f = sum(coeficiente[i] * y^i for i in range(n-1))
    indices = list(range(n-1))
    random.shuffle(indices)
    positivos = indices[0:d//2]
    negativos = indices[d//2:d]
    coeficiente = [0]*(n-1)

    for i in positivos:
        coeficiente[i] =1
    for i in negativos:
        coeficiente[i] =-1

    g = sum(coeficiente[i] * y^i for i in range(n-1))
    return f,g

    [f,g]=sample_fg(n,q)
