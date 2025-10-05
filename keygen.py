import random
import unittest


def sample_fg(S, n, q):
    d = q//8-2
    # coeficiente = [random.choice([-1, 0, 1]) for i in range(n-1)]
    coeficiente = random.choices([-1, 0, 1], k=n-1)
    # while sum(abs(c) for c in coeficiente)==0:
    while coeficiente == [0]*(n-1):
        # coeficiente = [random.choice([-1, 0, 1]) for i in range(n-1)]
        coeficiente = random.choices([-1, 0, 1], k=n-1)

    # f = sum(coeficiente[i] * y^i for i in range(n-1))
    f = S(coeficiente)
    indices = list(range(n-1))
    random.shuffle(indices)
    positivos = indices[0:d//2]
    negativos = indices[d//2:d]
    coeficiente = [0]*(n-1)

    for i in positivos:
        coeficiente[i] =1
    for i in negativos:
        coeficiente[i] =-1

    # g = sum(coeficiente[i] * y^i for i in range(n-1))
    g = S(coeficiente)
    return f,g

def keygen(S, Sq, n, q):
    f, g = sample_fg(S, n, q)

    

    return f, g, fq

class TestKeygen(unittest.TestCase):
    def setUp(self):
        self.qs = {}
        self.qs[509] = 2048
        self.qs[677] = 2048
        self.qs[821] = 4096
        self.ns = [509, 677, 821]
        self.p = 3

    def test_sample_fg(self):
        for n in self.ns: # 1.3.2
            # n = 509 # 1.3.2 
            # q = 2048 #potência de dois
            q = self.qs[n]

            #A polynomial is ternary if its coefficients are in {−1, 0, 1}.
            #R = PolynomialRing(ZZ, 'x') #define anel de polinômios com coeficientes inteiros
            #x = R.gen()
            R.<x> = ZZ[]
            Phi_n = (x^n-1)//(x-1) 
            S.<y> = R.quotient(Phi_n)

            for i in range(1000):
                f, g = sample_fg(S, n, q)

                self.assertLessEqual(f.lift().degree(), n-2)
                self.assertLessEqual(g.lift().degree(), n-2)
                self.assertTrue(all(c in [-1, 0, 1] for c in f.lift().list()))
                self.assertTrue(all(c in [-1, 0, 1] for c in g.lift().list()))
                self.assertNotEqual(f, 0)
                self.assertNotEqual(g, 0)

                self.assertEqual(sum(1 for c in g.lift().list() if c == 1), q//16 - 1)
                self.assertEqual(sum(1 for c in g.lift().list() if c == -1), q//16 - 1)

    # def test_keygen(self):
    #     for n in self.ns: # 1.3.2
    #         # n = 509 # 1.3.2 
    #         # q = 2048 #potência de dois
    #         q = self.qs[n]

    #         #A polynomial is ternary if its coefficients are in {−1, 0, 1}.
    #         #R = PolynomialRing(ZZ, 'x') #define anel de polinômios com coeficientes inteiros
    #         #x = R.gen()
    #         R.<x> = ZZ[]
    #         Phi_n = (x^n-1)//(x-1) 
    #         S.<y> = R.quotient(Phi_n)
    #         Sq.<z> = R.quotient(Phi_n, modulus=q)

    #         for i in range(1000):
    #             f, g, fq = keygen(S, Sq, n, q)

    #             # Fazer os testes
    #             self.assertEqual(fq * f, 1)


if __name__ == '__main__':
    unittest.main()