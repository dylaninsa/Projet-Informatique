Unit unite;


Interface


uses sysutils;


Const 
    MAX = 50;
    UP = #72;
	DOWN = #80;
	LEFT = #75;
	RIGHT = #77;
    QUIT = #113;
    SPACE = #32;

Type Enviro = (Manoir, INSA);

Type ListeCartes = (Colonel_Moutarde, Docteur_Olive, Madame_Pervenche, Mademoiselle_Rose, Professeur_Violet, Madame_Leblanc, Poignard, Chandelier, Revolver, Corde, Matraque, Clef_Anglaise, Cuisine, Grand_Salon, Petit_Salon, Salle_a_manger, Bureau, Bibliotheque, Veranda, Hall, Studio, Cluedo, Monsieur_Bredel, Madame_LArcheveque, Le_Directeur, Yohann_Lepailleur, Monsieur_Thibault, Infirmiere, Seringue, Moteur_4_temps, Alteres, Flacon_Acide, Ordi, Pouf_Rouge, Cafete, Amphi_Tillon, Infirmerie, Bureau_directeur, Toilettes, Vestiaires, DUBRJ11, Labo, BU, Accueil);

Type Coords = Array [1..2] of Integer;

Type Joueur = record
    enVie : Boolean;
	cartes : set of ListeCartes;
	pos : Coords;
	perso : ListeCartes;
    pion : Char;
end;

Type ListeJoueurs = Array of Joueur;

Type Salle = record
    nom : ListeCartes;
    cases : Array [1..MAX] of Coords;
end;

Type Plateau = record 
    grille : Array [1..MAX,1..MAX] of Integer;
    salles : Array [1..10] of Salle;
end;


function StrToListeCartes(carteAChanger: String): ListeCartes;


Implementation


function StrToListeCartes(carteAChanger: String): ListeCartes;

begin
    write(carteAChanger);
    carteAChanger := StringReplace(carteAChanger, '_', ' ', [rfReplaceAll, rfIgnoreCase]);

    case LowerCase(carteAChanger) of 
        'colonel moutarde' : StrToListeCartes := Colonel_Moutarde;
        'docteur olive': StrToListeCartes := Docteur_Olive;
        'madame pervenche' : StrToListeCartes := Madame_Pervenche;
        'mademoiselle rose': StrToListeCartes := Mademoiselle_Rose;
        'professeur violet' : StrToListeCartes := Professeur_Violet;
        'madame leblanc': StrToListeCartes := Madame_Leblanc;
        'poignard' : StrToListeCartes := Poignard;
        'chandelier' : StrToListeCartes := Chandelier;
        'revolver': StrToListeCartes := Revolver;
        'corde': StrToListeCartes := Corde;
        'matraque' : StrToListeCartes := Matraque;
        'clef anglaise': StrToListeCartes := Clef_Anglaise;
        'cuisine': StrToListeCartes := Cuisine;
        'grand salon' : StrToListeCartes := Grand_Salon;
        'petit salon': StrToListeCartes := Petit_Salon;
        'salle a manger': StrToListeCartes := Salle_a_manger;
        'bureau': StrToListeCartes := Bureau;
        'bibliotheque': StrToListeCartes := Bibliotheque;
        'veranda': StrToListeCartes := Veranda;
        'hall': StrToListeCartes := Hall;
        'studio' : StrToListeCartes := Studio;
        'cluedo' : StrToListeCartes := Cluedo;
        'monsieur bredel': StrToListeCartes := Monsieur_Bredel;
        'madame larcheveque' : StrToListeCartes := Madame_LArcheveque;
        'le directeur': StrToListeCartes := Le_Directeur;
        'yohann lepailleur' : StrToListeCartes := Yohann_Lepailleur;
        'monsieur thibault': StrToListeCartes := Monsieur_Thibault;
        'infirmiere': StrToListeCartes := Infirmiere;
        'seringue': StrToListeCartes := Seringue;
        'moteur 4 temps': StrToListeCartes := Moteur_4_temps;
        'alteres': StrToListeCartes := Alteres;
        'flacon acide': StrToListeCartes := Flacon_Acide;
        'ordi': StrToListeCartes := Ordi;
        'pouf rouge': StrToListeCartes := Pouf_Rouge;
        'cafete': StrToListeCartes := Cafete;
        'amphi tillon': StrToListeCartes := Amphi_Tillon;
        'infirmerie': StrToListeCartes := Infirmerie;
        'bureau directeur': StrToListeCartes := Bureau_directeur;
        'vestiaires': StrToListeCartes := Vestiaires;
        'toilettes': StrToListeCartes := Toilettes;
        'dubrj11' : StrToListeCartes := DUBRJ11;
        'labo': StrToListeCartes := Labo;
        'bu': StrToListeCartes := BU;
        'accueil': StrToListeCartes := Accueil;
    end;
end;


end.

