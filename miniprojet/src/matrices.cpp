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

bool operator==(complexe a, complexe b) {{{
    if(a.re == b.re && a.im == a.im) return true;
    return false;
}}}

bool operator!=(complexe a, complexe b) {{{
    return !(a==b);
}}}

complexe operator+(complexe a, complexe b) {{{
    a.re += b.re;
    a.im += b.im;
    return a;
}}}

complexe operator-(complexe a, complexe b) {{{
    a.re -= b.re;
    a.im -= b.im;
    return a;
}}}

complexe conjugue(complexe a) {{{
    a.im = -a.im;
    return a;
}}}

complexe operator*(complexe a, complexe b) {{{
    // (v+iw)(x+iy) = vx - wy + i(vy +wx)
    complexe c;
    c.re = a.re*b.re-a.im*b.im;
    c.im = a.re*b.im+a.im*b.re;
    return c;
}}}

complexe operator*(complexe a, float b) {{{
    a.re *= b;
    a.im *= b;
    return a;
}}}

complexe operator*(complexe a, double b) {{{
    a.re *= b;
    a.im *= b;
    return a;
}}}

complexe operator/(complexe a, complexe b) {{{
    // (v+iw)/(x+iy) = ((v+iw)(x-iy))/(x²+y²)
    return a*conjugue(b)/(pow(b.re,2)+pow(b.im,2));
}}}

complexe operator/(complexe a, float b) {{{
    a.re /= b;
    a.im /= b;
    return a;
}}}

complexe operator/(complexe a, double b) {{{
    a.re /= b;
    a.im /= b;
    return a;
}}}

complexe operator+=(complexe a, complexe b) {{{ // TODO : ne marche visiblement pas oO
    a.re += b.re;
    a.im += b.im;
    return a;
}}}

double norme(complexe a) {{{
    return sqrt(pow(a.re,2)+pow(a.im,2));
}}}

bool isnull(complexe a) {{{
    if(a.re == 0 && a.im == 0) return true;
    return false;
}}}

complexe pow(complexe a, int k) {{{
    complexe b = a;
    for(int i=1; i<k; i++) b = b * a;
    return b;
}}}
        
/****************************************************************
 *                  Construteurs et destructeurs                *
 ****************************************************************/

complexe::complexe() {{{
    re = 0;
    im = 0;
}}}

vecteur::vecteur(int dim) {{{
    assert(dim != 0);
    n = dim;
    coef = new complexe[dim];
}}}

vecteur::~vecteur() {{{
}}}

matricepleine::matricepleine(int lig, int col, int nzv) {{{
    assert(lig != 0 && col != 0 && nzv != 0);
    m = lig;
    n = col;
    nz = nzv;
    //TODO coef = new complexe[nzv][nzv];
}}}

matricepleine::~matricepleine() {{{
}}}

matricecreuseun::matricecreuseun(int lig, int col, int nzv) {{{
    assert(lig != 0 && col != 0 && nzv != 0);
    m = lig;
    n = col;
    nz = nzv;
    i = new int[nzv];
    j = new int[nzv];
    coef = new complexe[nzv];
}}}

matricecreuseun::~matricecreuseun() {{{
    /*
    delete i;
    delete j;
    delete coef;
    */
}}}

matricecreusedeux::matricecreusedeux(int lig, int col, int nzv) {{{
    assert(lig != 0 && col != 0 && nzv != 0);
    m = lig;
    n = col;
    nz = nzv;
    vals = new complexe[nzv];
    j = new int[nzv];
    II = new int[lig+1];
}}}

matricecreusedeux::~matricecreusedeux() {{{
}}}

/****************************************************************
 *                       Affichage de matrices                  *
 ****************************************************************/

void complexe::afficher() {{{
    if(im!=0) printf("%5.4g+i%-5.4g ", re, im);
    else printf("%12.11g ", re);
}}}

void vecteur::afficher() {{{
    cout << "[ ";
    for(int i=0;i<n;i++) coef[i].afficher();
    cout << "]" << endl;
}}}

void matricepleine::afficher() {{{
    cout << "⎡ ";
    for(int j=0;j<m;j++) coef[0][j].afficher();
    cout << "⎤" << endl;
    for(int i=1;i<n-1;i++) {
        cout << "⎢ ";
        for(int j=0;j<m;j++) coef[i][j].afficher();
        cout << "⎥" << endl;
    }
    cout << "⎣ ";
    for(int j=0;j<m;j++) coef[n-1][j].afficher();
    cout << "⎦" << endl;
}}}

void matricecreuseun::afficher() {{{
    cout << "  i  | ";
    for(int k=0;k<nz;k++) printf("%12d ",i[k]);
    cout << endl << "  j  | ";
    for(int k=0;k<nz;k++) printf("%12d ",j[k]);
    cout << endl << "coef | ";
    for(int k=0;k<nz;k++) coef[k].afficher();
    cout << endl;
}}}

void matricecreusedeux::afficher() {{{
    cout << "vals | ";
    for(int k=0;k<nz;k++) vals[k].afficher();
    cout << endl << "  j  | ";
    for(int k=0;k<nz;k++) printf("%12d ",j[k]);
    cout << endl << " II  | ";
    for(int k=0;k<=m;k++) printf("%12d ",II[k]);
    cout << endl;
}}}

/****************************************************************
 *                       Égalités de matrices                   *
 ****************************************************************/

bool operator==(vecteur a, vecteur b) {{{
    if (a.n != b.n) return false;
    for(int i=0;i<a.n;i++) if (a.coef[i] != b.coef[i]) return false;
    return true;
}}}

bool operator!=(vecteur a, vecteur b) {{{
    return !(a==b);
}}}

bool operator==(matricepleine A, matricepleine B) {{{
    if( A.n != B.n || A.m != B.m) return false;
    for(int i=0;i<A.n;i++) for(int j=0;j<A.m;j++) if (A.coef[i][j] != B.coef[i][j]) return false;
    return true;
}}}

bool operator!=(matricepleine A, matricepleine B) {{{
    return !(A==B);
}}}

bool operator==(matricecreuseun A, matricecreuseun B) {{{
    if (A.m != B.m || A.n != B.n || A.nz != B.nz) return false;
    if (estenbordel(A)) ordonne(A);
    if (estenbordel(B)) ordonne(B);
    for(int k=0;k<A.n;k++) if(A.i[k] != B.i[k] || A.j[k] != B.j[k] || A.coef[k] != B.coef[k]) return false;
    return true;
}}}

bool operator!=(matricecreuseun A, matricecreuseun B) {{{
    return !(A==B);
}}}

bool operator==(matricecreusedeux A, matricecreusedeux B) {{{
    if (A.m != B.m || A.n != B.n || A.nz != B.nz) return false;
    for (int k=0;k<A.nz;k++) if (A.vals[k] != B.vals[k] || A.j[k] != B.j[k]) return false;
    for (int k=0;k<=A.m;k++) if (A.II[k] != B.II[k]) return false;
    return true;
}}}

bool operator!=(matricecreusedeux A, matricecreusedeux B) {{{
    return !(A==B);
}}}

/****************************************************************
 *                   Multiplications de matrices                *
 ****************************************************************/

vecteur operator*(matricepleine M, vecteur v) {{{
    assert(M.m == v.n);
    vecteur w(M.n);
    for(int i=0;i<M.n;i++) for(int j=0;j<M.m;j++) w.coef[i] = w.coef[i] + v.coef[j]*M.coef[i][j];
    return w;
}}}

vecteur operator*(matricecreuseun M, vecteur v) {{{
    assert(M.m == v.n);
    vecteur w(M.n);
    for(int k=0;k<M.nz;k++) w.coef[M.i[k]] = w.coef[M.i[k]] + M.coef[k]*v.coef[M.j[k]];
    return w;
}}}

vecteur operator*(matricecreusedeux M, vecteur v) {{{
    assert(M.m == v.n);
    vecteur w(M.n);
    int a=0;
    for(int b=0;b<M.n;b++) while(a<M.II[b]) {
        w.coef[b] = w.coef[b] + M.vals[a]*v.coef[M.j[a]];
        a++;
    }
    return w;
}}}

/****************************************************************
 *                       Conversion de matrices                 *
 ****************************************************************/

matricecreuseun pleineversun(matricepleine A) {{{
    matricecreuseun B(A.m, A.n, A.nz);
    int cmpt = 0;
    for(int i=0;i<A.m;i++) {
        for(int j=0;j<A.n;j++) {
            if (!isnull(A.coef[i][j])) {
                B.i[cmpt] = i;
                B.j[cmpt] = j;
                B.coef[cmpt++] = A.coef[i][j];
            }
        }
    }
    return B;
}}}

matricecreusedeux pleineversdeux(matricepleine A) {{{
    matricecreusedeux B(A.m, A.n, A.nz);
    int cmptm = 0;
    int cmptnz = 0;
    for (int i=0;i<A.m;i++) {
        bool yadejaqqchsurlaligne = false;
        for(int j=0;j<A.n;j++) {
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

matricecreusedeux unversdeux(matricecreuseun A) {{{
    matricecreusedeux B(A.m, A.n, A.nz);
    int cmpt = -1;
    for(int i=0;i<B.nz;i++) {
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

matricecreuseun ordonne(matricecreuseun A) {{{
    matricecreuseun B(A.m, A.n, A.nz);
    int cmpt = 0;
    for(int i=0;i<A.m;i++) {
        for(int j=0;j<A.n;j++) {
            for(int k=0;k<A.nz;k++) {
                if (A.i[k] == i && A.j[k] == j) {
                    B.i[cmpt] = A.i[k];
                    B.j[cmpt] = A.j[k];
                    B.coef[cmpt].re = A.coef[k].re;
                    B.coef[cmpt].im = A.coef[k].im;
                    cmpt++;
                }
            }
        }
    } // TODO euh... y'a pas moyen de faire ça mieux ? N*N*nz opérations :s
    return B;
}}}

bool estenbordel(matricecreuseun A) {{{
    int i=-1;
    int j=-1;
    for(int a=0;a<A.nz;a++) {
        if (i < A.i[a] || ( i == A.i[a] && j < A.j[a] )) {
            i = A.i[a];
            j = A.j[a];
        }
        else return true;
    }
    return false;
}}}

/****************************************************************
 *                 Lecture/ecriture de matrices                 *
 ****************************************************************/

matricecreuseun lireun(string file, bool comp) {{{
    FILE * t;
    t = fopen(file.c_str(),"r");
    assert(t!=NULL);
    int m, n, nz;
    complexe coef;
    fscanf(t, "%d %d %d", &m, &n, &nz);
    matricecreuseun M(m, n, nz);
    for(int k=0; k<nz; k++) {
        if(comp) fscanf(t, "%d %d %lf %lf", &M.i[k], &M.j[k], &M.coef[k].re, &M.coef[k].im);
        else fscanf(t, "%d %d %lf", &M.i[k], &M.j[k], &M.coef[k].re);
    }
    fclose(t);
    return M;
}}}

int ecrire(matricecreuseun A, string file) {{{
    FILE * t; // Faudrait sécuriser ça
    t = fopen(file.c_str(),"w");
    fprintf(t, "%d %d %d\n", A.m, A.n, A.nz);
    for(int k=0; k<A.nz; k++) fprintf(t, "%d %d %lf %lf\n", A.i[k], A.j[k], A.coef[k].re, A.coef[k].im);
    fclose(t);
    return 0;
}}}

matricecreusedeux liredeux(string file, bool comp) {{{
    FILE * t;
    t = fopen(file.c_str(),"r");
    assert(t!=NULL);
    int m, n, nz;
    complexe vals;
    fscanf(t, "%d %d %d", &m, &n, &nz);
    matricecreusedeux M(m, n, nz);
    for(int k=0; k<=m; k++) fscanf(t, "%d", &M.II[k]);
    for(int k=0; k<nz; k++) {
        if(comp) fscanf(t, "%d %lf %lf", &M.j[k], &M.vals[k].re, &M.vals[k].im);
        else fscanf(t, "%d %lf", &M.j[k], &M.vals[k].re);
    }
    fclose(t);
    return M;
}}}

int ecrire(matricecreusedeux A, string file) {{{
    FILE * t; // Faudrait sécuriser ça
    t = fopen(file.c_str(),"w");
    fprintf(t, "%d %d %d\n", A.m, A.n, A.nz);
    for(int k=0; k<=A.m; k++) fprintf(t, "%d\n", A.II[k]);
    for(int k=0; k<A.nz; k++) fprintf(t, "%d %lf %lf\n", A.j[k], A.vals[k].re, A.vals[k].im);
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

matricecreuseun lireun(bool comp) {{{
    string nom = demandernomdufichier();
    return lireun(nom, comp);
}}}

int ecrire(matricecreuseun A) {{{
    string nom;
    cout << "Comment voulez-vous appeler le fichier ?" << endl << "==> " ;
    cin >> nom;
    return ecrire(A, nom);
}}}

matricecreusedeux liredeux(bool comp) {{{
    string nom = demandernomdufichier();
    return liredeux(nom, comp);
}}}

int ecrire(matricecreusedeux A) {{{
    string nom;
    cout << "Comment voulez-vous appeler le fichier ?" << endl << "==> " ;
    cin >> nom;
    return ecrire(A, nom);
}}}

/****************************************************************
 *                   Opérations vecteur-nombre                  *
 ****************************************************************/

float norme(vecteur v) {{{
    float n,m=0;
	int i;
	for (i=0; i<v.n; i++) {
		m += pow(norme(v.coef[i]),2);
	}
	n=sqrt(m);
    return n;
}}}

float abs(float x) {{{
    float y ;
    if ( x > 0 ) y = x ;
    else y = -x ;
    return y ;
}}}

vecteur operator/(vecteur v, float x) {{{
	for (int i=0; i<v.n; i++) v.coef[i] = v.coef[i]/x; // TODO /=
    return v;
}}}

vecteur operator*(vecteur v, float x) {{{
	for (int i=0; i<v.n; i++) v.coef[i] = v.coef[i]*x; // TODO /=
    return v;
}}}

vecteur operator *(vecteur v, complexe a){{{
    for(int i=0; i<v.n; i++) v.coef[i] = a*v.coef[i]; // TODO /=
    return v;
}}}

// vim: set foldmethod=marker:
