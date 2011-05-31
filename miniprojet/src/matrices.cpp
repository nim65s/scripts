#include <iostream>
#include <cstdio>
#include <string>
#include <cmath>
#include <assert.h>
#include "matrices.h"

using namespace std;

/****************************************************************
 *                           Complexes                          *
 ****************************************************************/

bool operator==(complexe const & a, complexe const & b) {{{
    if(a.re == b.re && a.im == a.im) return true;
    return false;
}}}

bool operator!=(complexe const & a, complexe const & b) {{{
    return !(a==b);
}}}

complexe operator+(complexe a, complexe const & b) {{{
    a.re += b.re;
    a.im += b.im;
    return a;
}}}

complexe operator-(complexe a, complexe const & b) {{{
    a.re -= b.re;
    a.im -= b.im;
    return a;
}}}

complexe conjugue(complexe a) {{{
    a.im = -a.im;
    return a;
}}}

complexe operator*(complexe const & a, complexe const & b) {{{
    // (v+iw)(x+iy) = vx - wy + i(vy +wx)
    complexe c;
    c.re = a.re*b.re-a.im*b.im;
    c.im = a.re*b.im+a.im*b.re;
    return c;
}}}

complexe operator*(complexe a, double const & b) {{{
    a.re *= b;
    a.im *= b;
    return a;
}}}

complexe operator/(complexe const & a, complexe const & b) {{{
    // (v+iw)/(x+iy) = ((v+iw)(x-iy))/(x²+y²)
    return a*conjugue(b)/(pow(b.re,2)+pow(b.im,2));
}}}

complexe operator/(complexe a, double const & b) {{{
    a.re /= b;
    a.im /= b;
    return a;
}}}

complexe & complexe::operator+=(complexe const & a) {{{
    re += a.re;
    im += a.im;
    return *this;
}}}

complexe & complexe::operator-=(complexe const & a) {{{
    re -= a.re;
    im -= a.im;
    return *this;
}}}

complexe & complexe::operator*=(complexe const & a) {{{
    complexe b;
    b.re = re*a.re-im*a.im;
    b.im = re*a.im+im*a.re;
    return b;
}}}

complexe & complexe::operator/=(complexe const & a) {{{
    complexe b;
    b.re = (re*a.re-im*a.im)/(pow(a.re,2)+pow(a.im,2));
    b.im = -(re*a.im+im*a.re)/(pow(a.re,2)+pow(a.im,2));
    return b;
}}}

complexe & complexe::operator*=(double const & x) {{{
    re *= x;
    im *= x;
    return *this;
}}}

complexe & complexe::operator/=(double const & x) {{{
    re /= x;
    im /= x;
    return *this;
}}}

double complexe::norme() const {{{
    return sqrt(pow(re,2)+pow(im,2));
}}}

bool complexe::isnull() const {{{
    if(re == 0 && im == 0) return true;
    return false;
}}}

complexe pow(complexe const & a, int const & k) {{{
    complexe b = a;
    for(int i(1); i<k; i++) b *= a;
    return b;
}}}
        
/****************************************************************
 *                  Construteurs et destructeurs                *
 ****************************************************************/

complexe::complexe() : re(0), im(0) {{{
}}}

complexe::complexe(double const & a) : re(a), im(0) {{{
}}}

complexe::complexe(double const & a, double const & b) : re(a), im(b) {{{
}}}

complexe::complexe(complexe const & a) : re(a.re), im(a.im) {{{
}}}

vecteur::vecteur(int const & dim) : n(dim) {{{
    assert(n != 0);
    coef = new complexe[n];
}}}

vecteur::vecteur(vecteur const & v) : n(v.n) {{{
    assert(n != 0);
    coef = new complexe[n];
    for(int i(0); i<n; i++) coef[i] = v.coef[i];
}}}

vecteur & vecteur::operator=(vecteur const & v) {{{
    if(this != &v) {
        n = v.n;
        delete [] coef;
        coef = new complexe(*(v.coef));
    }
    return *this;
}}}

vecteur::~vecteur() {{{
    delete [] coef;
}}}

matricepleine::matricepleine(int const & lig, int const & col, int const & nzv) : m(lig), n(col), nz(nzv) {{{
    assert(n != 0 && m != 0 && nz != 0);
    //TODO coef = new complexe[nzv][nzv];
}}}

matricepleine::matricepleine(matricepleine const & A) : m(A.m), n(A.n), nz(A.nz) {{{
    assert(n != 0 && m != 0 && nz != 0);
    for(int i(0); i<m; i++) for(int j(0); j<n; j++) coef[m][n] = A.coef[m][n];
    //TODO coef = new complexe[nzv][nzv];
}}}

matricepleine & matricepleine::operator=(matricepleine const & A) {{{
    if(this != &A) {
        m = A.m;
        n = A.n;
        nz = A.nz;
        for(int i(0); i<m; i++) for(int j(0); j<n; j++) coef[m][n] = A.coef[m][n];
    }
    return *this;
}}}

matricepleine::~matricepleine() {{{
}}}

matricecreuseun::matricecreuseun(int const & lig, int const & col, int const & nzv) : m(lig), n(col), nz(nzv) {{{
    assert(m != 0 && n != 0 && nz != 0);
    i = new int[nzv];
    j = new int[nzv];
    coef = new complexe[nzv];
}}}

matricecreuseun::matricecreuseun(matricecreuseun const & A) : m(A.m), n(A.n), nz(A.nz) {{{
    assert(m != 0 && n != 0 && nz != 0);
    i = new int[nz];
    j = new int[nz];
    coef = new complexe[nz];
    for (int k(0);k<A.nz;k++) {
        i[k] = A.i[k];
        j[k] = A.j[k];
        coef[k] = A.coef[k];
    }
}}}

matricecreuseun & matricecreuseun::operator=(matricecreuseun const & A) {{{
    if(this != &A) {
        m = A.m;
        n = A.n;
        nz = A.nz;
        delete [] i;
        delete [] j;
        delete [] coef;
        i = new int(*(A.i));
        j = new int(*(A.j));
        coef = new complexe(*(A.coef));
    }
    return *this;
}}}

matricecreuseun::~matricecreuseun() {{{
    delete [] i;
    delete [] j;
    delete [] coef;
}}}

matricecreusedeux::matricecreusedeux(int const & lig, int const & col, int const & nzv) : m(lig), n(col), nz(nzv) {{{
    assert(m != 0 && n != 0 && nz != 0);
    vals = new complexe[nzv];
    j = new int[nzv];
    II = new int[lig+1];
}}}

matricecreusedeux::matricecreusedeux(matricecreusedeux const & A) : m(A.m), n(A.n), nz(A.nz) {{{
    assert(m != 0 && n != 0 && nz != 0);
    vals = new complexe[nz];
    j = new int[nz];
    II = new int[m+1];
    for(int i(0); i<nz; i++) {
        vals[i] = A.vals[i];
        j[i] = A.j[i];
    }
    for(int i(0); i<=m; i++) II[i] = A.II[i];
}}}

matricecreusedeux & matricecreusedeux::operator=(matricecreusedeux const & A) {{{
    if(this != &A) {
        m = A.m;
        n = A.n;
        nz = A.nz;
        delete [] vals;
        delete [] j;
        delete [] II;
        vals = new complexe(*(A.vals));
        j = new int(*(A.j));
        II = new int(*(A.II));
    }
    return *this;
}}}

matricecreusedeux::~matricecreusedeux() {{{
    delete [] vals;
    delete [] j;
    delete [] II;
}}}

/****************************************************************
 *                       Affichage de matrices                  *
 ****************************************************************/

void complexe::afficher() const {{{
    if(im!=0) printf("%5.3e+i%-5.3e ", re, im);
    else printf("%12.11g ", re);
}}}

void vecteur::afficher() const {{{
    cout << "[ ";
    for(int i(0);i<n;i++) coef[i].afficher();
    cout << "]" << endl;
}}}

void matricepleine::afficher() const {{{
    cout << "⎡ ";
    for(int j(0);j<m;j++) coef[0][j].afficher();
    cout << "⎤" << endl;
    for(int i(1);i<n-1;i++) {
        cout << "⎢ ";
        for(int j(0);j<m;j++) coef[i][j].afficher();
        cout << "⎥" << endl;
    }
    cout << "⎣ ";
    for(int j(0);j<m;j++) coef[n-1][j].afficher();
    cout << "⎦" << endl;
}}}

void matricecreuseun::afficher() const {{{
    cout << "  i  | ";
    for(int k(0);k<nz;k++) printf("%12d ",i[k]);
    cout << endl << "  j  | ";
    for(int k(0);k<nz;k++) printf("%12d ",j[k]);
    cout << endl << "coef | ";
    for(int k(0);k<nz;k++) coef[k].afficher();
    cout << endl;
}}}

void matricecreusedeux::afficher() const {{{
    cout << "vals | ";
    for(int k(0);k<nz;k++) vals[k].afficher();
    cout << endl << "  j  | ";
    for(int k(0);k<nz;k++) printf("%12d ",j[k]);
    cout << endl << " II  | ";
    for(int k(0);k<=m;k++) printf("%12d ",II[k]);
    cout << endl;
}}}

/****************************************************************
 *                       Égalités de matrices                   *
 ****************************************************************/

bool operator==(vecteur const & a, vecteur const & b) {{{
    if (a.n != b.n) return false;
    for(int i(0);i<a.n;i++) if (a.coef[i] != b.coef[i]) return false;
    return true;
}}}

bool operator!=(vecteur const & a, vecteur const & b) {{{
    return !(a==b);
}}}

bool operator==(matricepleine const & A, matricepleine const & B) {{{
    if( A.n != B.n || A.m != B.m) return false;
    for(int i(0);i<A.n;i++) for(int j(0);j<A.m;j++) if (A.coef[i][j] != B.coef[i][j]) return false;
    return true;
}}}

bool operator!=(matricepleine const & A, matricepleine const & B) {{{
    return !(A==B);
}}}

bool operator==(matricecreuseun A, matricecreuseun B) {{{
    if (A.m != B.m || A.n != B.n || A.nz != B.nz) return false;
    if (A.estenbordel()) A = A.ordonne();
    if (B.estenbordel()) B = B.ordonne();
    for(int k(0);k<A.n;k++) if(A.i[k] != B.i[k] || A.j[k] != B.j[k] || A.coef[k] != B.coef[k]) return false;
    return true;
}}}

bool operator!=(matricecreuseun const & A, matricecreuseun const & B) {{{
    return !(A==B);
}}}

bool operator==(matricecreusedeux const & A, matricecreusedeux const & B) {{{
    if (A.m != B.m || A.n != B.n || A.nz != B.nz) return false;
    for (int k(0);k<A.nz;k++) if (A.vals[k] != B.vals[k] || A.j[k] != B.j[k]) return false;
    for (int k(0);k<=A.m;k++) if (A.II[k] != B.II[k]) return false;
    return true;
}}}

bool operator!=(matricecreusedeux const & A, matricecreusedeux const & B) {{{
    return !(A==B);
}}}

/****************************************************************
 *                   Multiplications de matrices                *
 ****************************************************************/

vecteur operator*(matricepleine const & M, vecteur const & v) {{{
    assert(M.m == v.n);
    vecteur w(M.n);
    for(int i(0);i<M.n;i++) for(int j(0);j<M.m;j++) w.coef[i] += v.coef[j]*M.coef[i][j];
    return w;
}}}

vecteur operator*(matricecreuseun const & M, vecteur const & v) {{{
    assert(M.m == v.n);
    vecteur w(M.n);
    for(int k(0);k<M.nz;k++) w.coef[M.i[k]] += M.coef[k]*v.coef[M.j[k]];
    return w;
}}}

vecteur operator*(matricecreusedeux const & M, vecteur const & v) {{{
    assert(M.m == v.n);
    vecteur w(M.n);
    int a(0);
    for(int b(0);b<M.n;b++) while(a<M.II[b]) {
        w.coef[b] += M.vals[a]*v.coef[M.j[a]];
        a++;
    }
    return w;
}}}

/****************************************************************
 *                       Conversion de matrices                 *
 ****************************************************************/

matricecreuseun matricepleine::versun() const {{{
    matricecreuseun A(m, n, nz);
    int cmpt(0);
    for(int i(0);i<m;i++) {
        for(int j(0);j<n;j++) {
            if (!coef[i][j].isnull()) {
                A.i[cmpt] = i;
                A.j[cmpt] = j;
                A.coef[cmpt++] = coef[i][j];
            }
        }
    }
    return A;
}}}

matricecreusedeux matricepleine::versdeux() const {{{
    matricecreusedeux A(m, n, nz);
    int cmptm(0);
    int cmptnz(0);
    bool yadejaqqchsurlaligne;
    for (int i(0);i<m;i++) {
        yadejaqqchsurlaligne = false;
        for(int j(0);j<n;j++) {
            if(!coef[i][j].isnull()) {
                A.vals[cmptnz] = coef[i][j];
                A.j[cmptnz++] = j;
                if (!yadejaqqchsurlaligne) {
                    yadejaqqchsurlaligne = true;
                    A.II[cmptm++] = cmptnz;
                }
            }
        }
        if (!yadejaqqchsurlaligne) A.II[cmptm++] = 0;
    }
    A.II[cmptm] = A.II[0]+cmptnz;
    return A;
}}}

matricecreusedeux matricecreuseun::versdeux() const {{{
    matricecreusedeux A(m, n, nz);
    int cmpt(-1);
    for(int a(0);a<nz;a++) {
        A.vals[a] = coef[a];
        A.j[a] = j[a];
        if (i[a] != cmpt) {
            if (i[a] == cmpt+1) A.II[++cmpt] = a+1;
            else A.II[++cmpt] = 0; 
        }
    }
    A.II[++cmpt] = A.II[0]+A.nz;
    return A;
}}}

/****************************************************************
 *                       Ordonnage de matrices                  *
 ****************************************************************/

matricecreuseun matricecreuseun::ordonne() const {{{
    matricecreuseun A(m, n, nz);
    int cmpt(0);
    for(int a(0);a<m;a++) {
        for(int b(0);b<n;b++) {
            for(int c(0);c<nz;c++) {
                if(i[c] == a && j[c] == b) {
                    A.i[cmpt] = i[c];
                    A.j[cmpt] = j[c];
                    A.coef[cmpt] = coef[c];
                    cmpt++;
                }
            }
        }
    } // TODO euh... y'a pas moyen de faire ça mieux ? N*N*nz opérations :s
    return A;
}}}

bool matricecreuseun::estenbordel() const{{{
    int a(-1);
    int b(-1);
    for(int c(0);c<nz;c++) {
        if (a < i[c] || ( a == i[c] && b < j[c] )) {
            a = i[c];
            b = j[c];
        }
        else return true;
    }
    return false;
}}}

/****************************************************************
 *                       Ordonnage de matrices                  *
 ****************************************************************/

matricecreuseun lireun(string const & file, bool const & comp) {{{
    FILE * t;
    t = fopen(file.c_str(),"r");
    assert(t!=NULL);
    int m, n, nz;
    complexe coef;
    fscanf(t, "%d %d %d", &m, &n, &nz);
    matricecreuseun M(m, n, nz);
    for(int k(0); k<nz; k++) {
        if(comp) fscanf(t, "%d %d %lf %lf", &M.i[k], &M.j[k], &M.coef[k].re, &M.coef[k].im);
        else fscanf(t, "%d %d %lf", &M.i[k], &M.j[k], &M.coef[k].re);
    }
    fclose(t);
    return M;
}}}

int matricecreuseun::ecrire(string const & file) const {{{
    FILE * t; // TODO Faudrait sécuriser ça
    t = fopen(file.c_str(),"w");
    fprintf(t, "%d %d %d\n", m, n, nz);
    for(int k(0); k<nz; k++) fprintf(t, "%d %d %lf %lf\n", i[k], j[k], coef[k].re, coef[k].im);
    fclose(t);
    return 0;
}}}

matricecreusedeux liredeux(string const & file, bool const & comp) {{{
    FILE * t;
    t = fopen(file.c_str(),"r");
    assert(t!=NULL);
    int m, n, nz;
    complexe vals;
    fscanf(t, "%d %d %d", &m, &n, &nz);
    matricecreusedeux M(m, n, nz);
    for(int k(0); k<=m; k++) fscanf(t, "%d", &M.II[k]);
    for(int k(0); k<nz; k++) {
        if(comp) fscanf(t, "%d %lf %lf", &M.j[k], &M.vals[k].re, &M.vals[k].im);
        else fscanf(t, "%d %lf", &M.j[k], &M.vals[k].re);
    }
    fclose(t);
    return M;
}}}

int matricecreusedeux::ecrire(string const & file) const {{{
    FILE * t; // TODO Faudrait sécuriser ça
    t = fopen(file.c_str(),"w");
    fprintf(t, "%d %d %d\n", m, n, nz);
    for(int k(0); k<=m; k++) fprintf(t, "%d\n", II[k]);
    for(int k(0); k<nz; k++) fprintf(t, "%d %lf %lf\n", j[k], vals[k].re, vals[k].im);
    fclose(t);
    return 0;
}}}

string demandernomdufichier() {{{
    string a, b, c, d, e, f;
    char rep;
    a = "../test.mx";
    b = "../A398.mx";
    c = "../A62.mx";
    d = "../B398.mx";
    e = "../B62.mx";
    f = "En entrer un autre";
    cout << "Quel fichier voulez vous lire ?" << endl;
    cout << "a) " << a << endl;
    cout << "b) " << b << endl;
    cout << "c) " << c << endl;
    cout << "d) " << d << endl;
    cout << "e) " << e << endl;
    cout << "f) " << e << endl;
    cout << "==> ";
    cin >> rep;
    string choix; // TODO l'idée était de faire un * choix...
    switch (rep) {
        case 'a':
            choix = a;
            break;
        case 'b':
            choix = b;
            break;
        case 'c':
            choix = c;
            break;
        case 'd':
            choix = d;
            break;
        case 'e':
            choix = d;
            break;
        case 'f':
            cin >> choix;
            break;
        default :
            assert(false);
            break;
    }
    return choix;
}}}

matricecreuseun lireun(bool const & comp) {{{
    return lireun(demandernomdufichier(), comp);
}}}

int matricecreuseun::ecrire() const {{{
    string nom;
    cout << "Comment voulez-vous appeler le fichier ?" << endl << "==> " ;
    cin >> nom;
    return ecrire(nom);
}}}

matricecreusedeux liredeux(bool const & comp) {{{
    return liredeux(demandernomdufichier(), comp);
}}}

int matricecreusedeux::ecrire() const {{{
    string nom;
    cout << "Comment voulez-vous appeler le fichier ?" << endl << "==> " ;
    cin >> nom;
    return ecrire(nom);
}}}

/****************************************************************
 *                   Opérations vecteur-nombre                  *
 ****************************************************************/

double vecteur::norme() const {{{
    double m(0);
	for (int i(0); i<n; i++) m += pow(coef[i].norme(),2);
    return sqrt(m);
}}}

vecteur operator/(vecteur v, double const & x) {{{
	for (int i(0); i<v.n; i++) v.coef[i] /= x;
    return v;
}}}

vecteur operator*(vecteur v, double const & x) {{{
	for (int i(0); i<v.n; i++) v.coef[i] *= x;
    return v;
}}}

vecteur operator *(vecteur v, complexe const & a){{{
    for(int i(0); i<v.n; i++) v.coef[i] *= a;
    return v;
}}}

// vim: set foldmethod=marker:
