#include <iostream>
#include <cstdio>
#include <string>
#include "matrices.h"

using namespace std;

/****************************************************************
 *                  Construteurs et destructeurs                *
 ****************************************************************/

vecteur::vecteur(int dim) {{{
    n = dim;
    coef = new float[dim];
    for(int i=0;i<dim;i++) coef[i] = 0;
}}}

vecteur::~vecteur() {{{
}}}

matricepleine::matricepleine(int lig, int col, int nzv) {{{
    m = lig;
    n = col;
    nz = nzv;
    //TODO coef = new float[nzv][nzv];
    for(int i=0;i<lig;i++) for(int j=0;j<col;j++) coef[i][j] = 0;
}}}

matricepleine::~matricepleine() {{{
}}}

matricecreuseun::matricecreuseun(int lig, int col, int nzv) {{{
    // TODO là on pourrait vérifier que c'est pas nul...
    m = lig;
    n = col;
    nz = nzv;
    i = new int[nzv];
    j = new int[nzv];
    coef = new float[nzv];
}}}

matricecreuseun::~matricecreuseun() {{{
    /*
    cout << "destruc" << endl;
    delete i;
    delete j;
    delete coef;
    */
}}}

matricecreusedeux::matricecreusedeux(int lig, int col, int nzv) {{{
    m = lig;
    n = col;
    nz = nzv;
    vals = new float[nzv];
    j = new int[nzv];
    II = new int[lig+1];
}}}

matricecreusedeux::~matricecreusedeux() {{{
}}}

/****************************************************************
 *                       Affichage de matrices                  *
 ****************************************************************/

void vecteur::afficher() {{{
    cout << "[";
    for(int i=0;i<n;i++) {
        printf("%5.2g",coef[i]);
        cout << " ";
    }
    cout << "  ]" << endl;
}}}

void matricepleine::afficher() {{{
    cout << "⎡";
    for(int j=0;j<m;j++) printf("%5.4g ",coef[0][j]);
    cout << "  ⎤" << endl;
    for(int i=1;i<n-1;i++) {
        cout << "⎢";
        for(int j=0;j<m;j++) printf("%5.4g ",coef[i][j]);
        cout << "  ⎥" << endl;
    }
    cout << "⎣";
    for(int j=0;j<m;j++) printf("%5.4g ",coef[n-1][j]);
    cout << "  ⎦" << endl;
}}}

void matricecreuseun::afficher() {{{
    cout << "  i  | ";
    for(int k=0;k<nz;k++) printf("%5d ",i[k]);
    cout << endl << "  j  | ";
    for(int k=0;k<nz;k++) printf("%5d ",j[k]);
    cout << endl << "coef | ";
    for(int k=0;k<nz;k++) printf("%5.4g ",coef[k]);
    cout << endl;
}}}

void matricecreusedeux::afficher() {{{
    cout << "vals | ";
    for(int k=0;k<nz;k++) printf("%5.4g ",vals[k]);
    cout << endl << "  j  | ";
    for(int k=0;k<nz;k++) printf("%5d ",j[k]);
    cout << endl << " II  | ";
    for(int k=0;k<=m;k++) printf("%5d ",II[k]);
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
    if (M.m != v.n) {
        cout << "On ne peut pas multiplier cette matrice et ce vecteur pour des raisons de dimension." << endl;
        cout << "Le vecteur retourné par cette multiplication est le vecteur initial !" << endl;
        return v;
    }
    vecteur w(M.n);
    for(int i=0;i<M.n;i++) for(int j=0;j<M.m;j++) w.coef[i] += v.coef[j]*M.coef[i][j];
    return w;
}}}

vecteur operator*(matricecreuseun M, vecteur v) {{{
    if (M.m != v.n) {
        cout << "On ne peut pas multiplier cette matrice et ce vecteur pour des raisons de dimension." << endl;
        cout << "Le vecteur retourné par cette multiplication est le vecteur initial !" << endl;
        return v;
    }
    vecteur w(M.n);
    for(int k=0;k<M.nz;k++) w.coef[M.i[k]] += M.coef[k]*v.coef[M.j[k]];
    return w;
}}}

vecteur operator*(matricecreusedeux M, vecteur v) {{{
    if (M.m != v.n) {
        cout << "On ne peut pas multiplier cette matrice et ce vecteur pour des raisons de dimension." << endl;
        cout << "Le vecteur retourné par cette multiplication est le vecteur initial !" << endl;
        return v;
    }
    vecteur w(M.n);
    int a=0;
    for(int b=0;b<M.n;b++) while(a<M.II[b]) {
        w.coef[b] += M.vals[a]*v.coef[M.j[a]];
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
            if (A.coef[i][j] != 0) {
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
            if(A.coef[i][j] != 0) {
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
            else B.II[++cmpt] = 0; // TODO il faut aussi rajouter la suite ...
        }
    }
    B.II[++cmpt] = B.II[0]+B.nz;
    return B;
}}}

/****************************************************************
 *                       Ordonage de matrices                   *
 ****************************************************************/

matricecreuseun ordonne(matricecreuseun A) {{{
    //cout << A.nz << endl;
    matricecreuseun B(A.m, A.n, A.nz);
    int cmpt = 0;
    for(int i=0;i<A.m;i++) {
        //cout << i;
        for(int j=0;j<A.n;j++) {
            //cout << "\t" << j;
            for(int k=0;k<A.nz;k++) {
                //cout << "\t" << k << endl;
                if (A.i[k] == i && A.j[k] == j) {
                    B.i[cmpt] = A.i[k];
                    B.j[cmpt] = A.j[k];
                    B.coef[cmpt++] = A.coef[k];
                    //cout << cmpt << endl;
                }
            }
        }
    } // TODO euh... y'a pas moyen de faire ça mieux ? XD
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
 *                       Lecture ecriture                       *
 ****************************************************************/

matricecreuseun lireun() {{{
    FILE * t;
    string a, b, c, d, e;
    char rep;
    a = "../test.mx";
    b = "../A62.mx";
    c = "../B398.mx";
    d = "../B62.mx";
    e = "La réponse e";
    cout << "Quel fichier voulez vous lire ?" << endl;
    cout << "a) " << a << endl;
    cout << "b) " << b << endl;
    cout << "c) " << c << endl;
    cout << "d) " << d << endl;
    cout << "e) " << "En entrer un autre" << endl;
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
            cin >> choix;
            break;
        default :
            //exit(1); // TODO 
            break;
    }

    t = fopen(choix.c_str(),"r");
    //if(t==NULL) { // TODO dans la doc y'a "the file must exit"
    int m, n, nz, i, j;
    float coef;
    fscanf(t, "%d %d %d", &m, &n, &nz);
    matricecreuseun M(m, n, nz);
    for(int k=0; k<nz; k++) {
        fscanf(t, "%d %d %f", &i, &j, &coef);
        M.i[k] = i;
        M.j[k] = j;
        M.coef[k] = coef;
    }
    fclose(t);
    return M;
}}}

int ecrire(matricecreuseun A) {{{
    FILE * t;
    string nom;
    cout << "Comment voulez-vous appeller le ficher ?" << endl << "==> " ;
    cin >> nom;
    t = fopen(nom.c_str(),"w"); // TODO On risque d'écraser des trucs ça craint
    fprintf(t, "%d %d %d\n", A.m, A.n, A.nz);
    for(int k=0; k<A.nz; k++) fprintf(t, "%d %d %f\n", A.i[k], A.j[k], A.coef[k]);
    fclose(t);
    return 0;
}}}

matricecreusedeux liredeux() {{{
    FILE * f;
    string a, b, c, d, e;
    char rep;
    a = "../test.mxb";
    b = "../A62.mxb";
    c = "../B398.mxb";
    d = "../B62.mxb";
    e = "La réponse e"; // TODO : entrez un autre fichier
    cout << "Quel fichier voulez vous lire ?" << endl;
    cout << "a) " << a << endl;
    cout << "b) " << b << endl;
    cout << "c) " << c << endl;
    cout << "d) " << d << endl;
    cout << "e) " << "En entrer un autre" << endl;
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
            cin >> choix;
            break;
        default :
            //exit(1); // TODO 
            break;
    }

    f = fopen(choix.c_str(),"rb");
    //if(t!=NULL) { // TODO dans la doc y'a "the file must exit"
    int m, n, nz, j, II;
    float vals;
    fscanf(f, "%d %d %d", &m, &n, &nz);
    matricecreusedeux M(m, n, nz);
    for(int k=0; k<=m; k++) {
        fscanf(f, "%d", &II);
        M.II[k] = II;
    }
    for(int k=0; k<nz; k++) {
        fscanf(f, "%d %f", &j, &vals);
        M.j[k] = j;
        M.vals[k] = vals;
    }
    fclose(f);
    return M;
}}}

int ecrire(matricecreusedeux A) {{{
    FILE * b;
    string nom;
    cout << "Comment voulez-vous appeller le ficher ?" << endl << "==> " ;
    cin >> nom;
    b = fopen(nom.c_str(),"wb"); // TODO On risque d'écraser des trucs ça craint
    fprintf(b, "%d %d %d\n", A.m, A.n, A.nz);
    for(int k=0; k<=A.m; k++) fprintf(b, "%d\n", A.II[k]);
    for(int k=0; k<A.nz; k++) fprintf(b, "%d %f\n", A.j[k], A.vals[k]);
    fclose(b);
    return 0;
}}}

// Les même avec le nom en paramètre

matricecreuseun lireun(string file) {{{
    FILE * t;
    t = fopen(file.c_str(),"r");
    //if(t==NULL) { // TODO dans la doc y'a "the file must exit"
    int m, n, nz, i, j;
    float coef;
    fscanf(t, "%d %d %d", &m, &n, &nz);
    matricecreuseun M(m, n, nz);
    for(int k=0; k<nz; k++) {
        fscanf(t, "%d %d %f", &i, &j, &coef);
        M.i[k] = i;
        M.j[k] = j;
        M.coef[k] = coef;
    }
    fclose(t);
    return M;
}}}

int ecrire(matricecreuseun A, string file) {{{
    FILE * t;
    t = fopen(file.c_str(),"w"); // TODO On risque d'écraser des trucs ça craint
    fprintf(t, "%d %d %d\n", A.m, A.n, A.nz);
    for(int k=0; k<A.nz; k++) fprintf(t, "%d %d %f\n", A.i[k], A.j[k], A.coef[k]);
    fclose(t);
    return 0;
}}}

matricecreusedeux liredeux(string file) {{{
    FILE * f;
    f = fopen(file.c_str(),"rb");
    //if(t!=NULL) { // TODO dans la doc y'a "the file must exit"
    int m, n, nz, j, II;
    float vals;
    fscanf(f, "%d %d %d", &m, &n, &nz);
    matricecreusedeux M(m, n, nz);
    for(int k=0; k<=m; k++) {
        fscanf(f, "%d", &II);
        M.II[k] = II;
    }
    for(int k=0; k<nz; k++) {
        fscanf(f, "%d %f", &j, &vals);
        M.j[k] = j;
        M.vals[k] = vals;
    }
    fclose(f);
    return M;
}}}

int ecrire(matricecreusedeux A, string file) {{{
    FILE * b;
    b = fopen(file.c_str(),"wb"); // TODO On risque d'écraser des trucs ça craint
    fprintf(b, "%d %d %d\n", A.m, A.n, A.nz);
    for(int k=0; k<=A.m; k++) fprintf(b, "%d\n", A.II[k]);
    for(int k=0; k<A.nz; k++) fprintf(b, "%d %f\n", A.j[k], A.vals[k]);
    fclose(b);
    return 0;
}}}

// vim: set foldmethod=marker:
