#include <iostream>
#include <cstdio>
#include <string>
#include <assert.h>
#include <math.h>
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

double norme(complexe const & a) {{{
    return sqrt(pow(a.re,2)+pow(a.im,2));
}}}

bool isnull(complexe const & a) {{{
    if(a.re == 0 && a.im == 0) return true;
    return false;
}}}

complexe pow(complexe const & a, int const & k) {{{
    complexe b = a;
    for(int i(1); i<k; i++) b = b * a;
    return b;
}}}
        
/****************************************************************
 *                  Construteurs et destructeurs                *
 ****************************************************************/

complexe::complexe() : re(0), im(0) {{{
}}}

vecteur::vecteur(int const & dim) : n(dim) {{{
    assert(dim != 0);
    coef = new complexe[dim];
}}}

vecteur::~vecteur() {{{
}}}

matricepleine::matricepleine(int const & lig, int const & col, int const & nzv) : m(lig), n(col), nz(nzv) {{{
    assert(n != 0 && m != 0 && nz != 0);
    //TODO coef = new complexe[nzv][nzv];
}}}

matricepleine::~matricepleine() {{{
}}}

/*
matricecreuseun::matricecreuseun(const matricecreuseun & A) : m(A.m), n(A.n), nz(A.nz) {{{
    i = new int[A.nz];
    j = new int[A.nz];
    coef = new complexe[A.nz];
    for (int p(0);p<A.nz;p++) {
        i[p] = A.i[p];
        j[p] = A.j[p];
        coef[p] = A.coef[p];
    }
}}}
*/

matricecreuseun::matricecreuseun(int const & lig, int const & col, int const & nzv) : m(lig), n(col), nz(nzv) {{{
    assert(m != 0 && n != 0 && nz != 0);
    i = new int[nzv];
    j = new int[nzv];
    coef = new complexe[nzv];
}}}

matricecreuseun::~matricecreuseun() {{{
    /*
    delete [] i;
    delete [] j;
    delete [] coef;
    */
}}}

matricecreusedeux::matricecreusedeux(int const & lig, int const & col, int const & nzv) : m(lig), n(col), nz(nzv) {{{
    assert(m != 0 && n != 0 && nz != 0);
    vals = new complexe[nzv];
    j = new int[nzv];
    II = new int[lig+1];
}}}

matricecreusedeux::~matricecreusedeux() {{{
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

bool operator==(matricecreuseun const & A, matricecreuseun const & B) {{{
    if (A.m != B.m || A.n != B.n || A.nz != B.nz) return false;
    if (estenbordel(A)) ordonne(A);
    if (estenbordel(B)) ordonne(B);
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

matricecreuseun pleineversun(matricepleine const & A) {{{
    matricecreuseun B(A.m, A.n, A.nz);
    int cmpt(0);
    for(int i(0);i<A.m;i++) {
        for(int j(0);j<A.n;j++) {
            if (!isnull(A.coef[i][j])) {
                B.i[cmpt] = i;
                B.j[cmpt] = j;
                B.coef[cmpt++] = A.coef[i][j];
            }
        }
    }
    return B;
}}}

matricecreusedeux pleineversdeux(matricepleine const & A) {{{
    matricecreusedeux B(A.m, A.n, A.nz);
    int cmptm(0);
    int cmptnz(0);
    bool yadejaqqchsurlaligne;
    for (int i(0);i<A.m;i++) {
        yadejaqqchsurlaligne = false;
        for(int j(0);j<A.n;j++) {
            if(!isnull(A.coef[i][j])) {
                B.vals[cmptnz] = A.coef[i][j];
                B.j[cmptnz++] = j;
                if (!yadejaqqchsurlaligne) {
                    yadejaqqchsurlaligne = true;
                    B.II[cmptm++] = cmptnz;
                }
            }
        }
        if (!yadejaqqchsurlaligne) B.II[cmptm++] = 0;
    }
    B.II[cmptm] = B.II[0]+cmptnz;
    return B;
}}}

matricecreusedeux unversdeux(matricecreuseun const & A) {{{
    matricecreusedeux B(A.m, A.n, A.nz);
    int cmpt(-1);
    for(int i(0);i<B.nz;i++) {
        B.vals[i] = A.coef[i];
        B.j[i] = A.j[i];
        if (A.i[i] != cmpt) {
            if (A.i[i] == cmpt+1) B.II[++cmpt] = i+1;
            else B.II[++cmpt] = 0; 
        }
    }
    B.II[++cmpt] = B.II[0]+B.nz;
    return B;
}}}

/****************************************************************
 *                       Ordonnage de matrices                  *
 ****************************************************************/

matricecreuseun ordonne(matricecreuseun const & A) {{{
    matricecreuseun B(A.m, A.n, A.nz);
    int cmpt(0);
    for(int i(0);i<A.m;i++) {
        for(int j(0);j<A.n;j++) {
            for(int k(0);k<A.nz;k++) {
                if (A.i[k] == i && A.j[k] == j) {
                    B.i[cmpt] = A.i[k];
                    B.j[cmpt] = A.j[k];
                    /* TODO
                    B.coef[cmpt].re = A.coef[k].re;
                    B.coef[cmpt].im = A.coef[k].im;
                    */
                    B.coef[cmpt] = A.coef[k];
                    cmpt++;
                }
            }
        }
    } // TODO euh... y'a pas moyen de faire ça mieux ? N*N*nz opérations :s
    return B;
}}}

bool estenbordel(matricecreuseun const & A) {{{
    int i(-1);
    int j(-1);
    for(int a(0);a<A.nz;a++) {
        if (i < A.i[a] || ( i == A.i[a] && j < A.j[a] )) {
            i = A.i[a];
            j = A.j[a];
        }
        else return true;
    }
    return false;
}}}

/****************************************************************
 *                   Opérations vecteur-nombre                  *
 ****************************************************************/

double norme(vecteur const & v) {{{
    double m(0);
	for (int i(0); i<v.n; i++) m += pow(norme(v.coef[i]),2);
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
