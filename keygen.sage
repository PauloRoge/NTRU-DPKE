
import random
import unittest

def sample_fg(S, n, q):
    d = q//8-2
    f_coeffs = random.choices([-1, 0, 1], k=n-1)
    while not any(f_coeffs):                            # para n pequeno
        f_coeffs = random.choices([-1, 0, 1], k=n-1)
    
    ind = list(range(n-1))
    random.shuffle(ind)
    pos = ind[0:d//2]
    neg = ind[d//2:d]

    g_coeffs = [0]*(n-1)
    for i in pos:
        g_coeffs[i] = 1
    for i in neg:
        g_coeffs[i] = -1
    return f_coeffs, g_coeffs 

def keygen(S, S3, Sq, Rq, n, q):
    for attempt in range(1000):
        f_coeffs, g_coeffs = sample_fg(S, n, q)
        
        try:
            fq = 1 / Sq(f_coeffs)
            print(f"[n,q]=[{n},{q}], attempt: {attempt + 1}")
            return f_coeffs, fq
            
        except (ZeroDivisionError, ArithmeticError):
            continue
    
    raise ValueError("limite de tentativas")

class TestKeygen(unittest.TestCase):
    def setUp(self):
        self.qs = {}
        self.rings = {}
        self.qs[5] = 32 
        self.qs[7] = 32   
        self.ns = [5, 7]
        self.p = 3

        for n in self.ns:
            q = self.qs[n]
            R.<x> = ZZ[]
            Phi_n = (x^n-1)//(x-1)
            Phi_1 = (x - 1)
            S.<y> = R.quotient(Phi_n)
            Sq.<z> = R.quotient(Phi_n, modulus=q)
            Rq.<z_R> = R.quotient(Phi_1 * Phi_n, modulus=q)
            S3.<y3> = R.quotient(Phi_n, modulus=3)
            
            self.rings[(n, q)] = {
                'S'    :  S,
                'Sq'   :  Sq,
                'Rq'   :  Rq,
                'S3'   :  S3,
                'R'    :  R,
                'Phi_n':  Phi_n
            }

    def test_parameters(self):
        for n in self.ns:
            q = self.qs[n]
            d = q//8 - 2
            self.assertEqual(q % 8, 0, f"q={q} deve ser múltiplo de 8")
            self.assertGreater(d, 0, f"d={d} deve ser positivo")
            self.assertEqual(d % 2, 0, f"d={d} deve ser par")
            self.assertLessEqual(d, 2*n//3, f"d={d} não pode ser maior que 2n/3={2*n//3}")

    def test_sample_fg(self):
        for n in self.ns:
            q = self.qs[n]
            rings = self.rings[(n, q)]

            for i in range(10):
                f_coeffs, g_coeffs = sample_fg(rings['S'], n, q) 
                f = rings['S'](f_coeffs) 
                g = rings['S'](g_coeffs)

                f_lift = f.lift()              # reconstruir polinômios
                g_lift = g.lift()              # apenas uma vez 
                deg_f  = f_lift().degree()
                deg_g  = g_lift().degree()
                self.assertLessEqual(deg_f, n-2)
                self.assertLessEqual(deg_g, n-2)
                self.assertTrue(all(c in [-1, 0, 1] for c in f_lift().list()))
                self.assertTrue(all(c in [-1, 0, 1] for c in g_lift().list()))
                self.assertNotEqual(f, 0)
                self.assertNotEqual(g, 0)
                self.assertEqual(sum(1 for c in g_lift().list() if c == 1), q//16 - 1)
                self.assertEqual(sum(1 for c in g_lift().list() if c == -1), q//16 - 1)

    def test_inverse(self):
        for n in self.ns:
            q = self.qs[n]
            rings = self.rings[(n, q)]

            for i in range(2):
                f_coeffs, fq = keygen(rings['S'], rings['S3'], rings['Sq'], rings['Rq'], n, q)

                f_in_Sq = rings['Sq'](f_coeffs)
                self.assertEqual(f_in_Sq * fq, 1)

unittest.main(argv=[''], exit=False)

# OBS; trecho do profiling gerado por ia:
# Cria a instância do TestCase
t = TestKeygen()
t.setUp()  # inicializa os rings e variáveis compartilhadas

# Profiling do método test_parameters
print("Profiling test_parameters:")
%prun -l 10 t.test_parameters()  # -l 10 limita a exibição às 10 funções mais gastas

# Profiling do método test_sample_fg
print("\nProfiling test_sample_fg:")
t.setUp()  # garante que qualquer estado residual seja reinicializado
%prun -l 20 t.test_sample_fg()  # -l 20 para ver mais detalhes de funções internas

# Profiling do método test_inverse
print("\nProfiling test_inverse:")
t.setUp()
%prun -l 30 t.test_inverse()  # -l 30 para ver mais detalhes dentro do keygen
