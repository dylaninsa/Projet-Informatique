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

Type ListeCartes = (Colonel_Moutarde, Docteur_Olive, Madame_Pervenche, Mademoiselle_Rose, Professeur_Violet, Madame_Leblanc, Poignard, Chandelier, Revolver, Corde, Matraque, Clef_Anglaise, Cuisine, Grand_Salon, Petit_Salon, Salle_a_manger, Bureau, Bibliotheque, Veranda, Hall, Studio, Cluedo, Monsieur_Bredel, Madame_LArcheveque, Directeur, Yohann_Lepailleur, Monsieur_Thibault, Infirmiere, Seringue, Moteur_4_temps, Alteres, Flacon_DAcide, Ordi, Pouf_Rouge, Cafete, Amphi_Tillon, Infirmerie, Bureau_directeur, Toilettes, Vestiaires, DUBRJ11, Labo, BU, Accueil);

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
function ListeCartesToStr(carte : ListeCartes) : String;


Implementation


function StrToListeCartes(carteAChanger: String): ListeCartes;

begin
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
        'madame l''archeveque' : StrToListeCartes := Madame_LArcheveque;
        'directeur': StrToListeCartes := Directeur;
        'yohann lepailleur' : StrToListeCartes := Yohann_Lepailleur;
        'monsieur thibault': StrToListeCartes := Monsieur_Thibault;
        'infirmiere': StrToListeCartes := Infirmiere;
        'seringue': StrToListeCartes := Seringue;
        'moteur 4 temps': StrToListeCartes := Moteur_4_temps;
        'alteres': StrToListeCartes := Alteres;
        'flacon d''acide': StrToListeCartes := Flacon_DAcide;
        'ordi': StrToListeCartes := Ordi;
        'pouf rouge': StrToListeCartes := Pouf_Rouge;
        'cafete': StrToListeCartes := Cafete;
        'amphi tillon': StrToListeCartes := Amphi_Tillon;
        'infirmerie': StrToListeCartes := Infirmerie;
        'bureau du directeur': StrToListeCartes := Bureau_directeur;
        'vestiaires': StrToListeCartes := Vestiaires;
        'toilettes': StrToListeCartes := Toilettes;
        'dubrj11' : StrToListeCartes := DUBRJ11;
        'labo': StrToListeCartes := Labo;
        'bu': StrToListeCartes := BU;
        'accueil': StrToListeCartes := Accueil
    end;
end;



function ListeCartesToStr(carte : ListeCartes) : String;

begin
    case carte of
        Colonel_Moutarde : ListeCartesToStr := 'Colonel Moutarde';
        Docteur_Olive : ListeCartesToStr := 'Docteur Olive';
        Madame_Pervenche : ListeCartesToStr := 'Madame Pervenche';
        Mademoiselle_Rose : ListeCartesToStr := 'Mademoiselle Rose';
        Professeur_Violet : ListeCartesToStr := 'Professeur Violet';
        Madame_Leblanc : ListeCartesToStr := 'Madame Leblanc';
        Poignard : ListeCartesToStr := 'poignard';
        Chandelier : ListeCartesToStr := 'chandelier';
        Revolver : ListeCartesToStr := 'revolver';
        Corde : ListeCartesToStr := 'corde';
        Matraque : ListeCartesToStr := 'matraque';
        Clef_Anglaise : ListeCartesToStr := 'clef anglaise';
        Cuisine : ListeCartesToStr := 'cuisine';
        Grand_Salon : ListeCartesToStr := 'grand salon';
        Petit_Salon : ListeCartesToStr := 'petit salon';
        Salle_a_manger : ListeCartesToStr := 'salle a manger';
        Bureau : ListeCartesToStr := 'bureau';
        Bibliotheque : ListeCartesToStr := 'bibliotheque';
        Veranda : ListeCartesToStr := 'veranda';
        Hall : ListeCartesToStr := 'hall';
        Studio : ListeCartesToStr := 'studio';
        Cluedo : ListeCartesToStr := 'cluedo';
        Monsieur_Bredel : ListeCartesToStr := 'Monsieur Bredel';
        Madame_LArcheveque : ListeCartesToStr := 'Madame L''Archeveque';
        Directeur : ListeCartesToStr := 'Directeur';
        Yohann_Lepailleur : ListeCartesToStr := 'Yohann Lepailleur';
        Monsieur_Thibault : ListeCartesToStr := 'Monsieur Thibault';
        Infirmiere : ListeCartesToStr := 'Infirmiere';
        Seringue : ListeCartesToStr := 'seringue';
        Moteur_4_temps : ListeCartesToStr := 'moteur 4 temps';
        Alteres : ListeCartesToStr := 'alteres';
        Flacon_DAcide : ListeCartesToStr := 'flacon d''acide';
        Ordi : ListeCartesToStr := 'ordi';
        Pouf_Rouge : ListeCartesToStr := 'pouf rouge';
        Cafete : ListeCartesToStr := 'cafete';
        Amphi_Tillon : ListeCartesToStr := 'amphi Tillon';
        Infirmerie : ListeCartesToStr := 'infirmerie';
        Bureau_directeur : ListeCartesToStr := 'bureau du Directeur';
        Toilettes : ListeCartesToStr := 'toilettes';
        Vestiaires : ListeCartesToStr := 'vestiaires';
        DUBRJ11 : ListeCartesToStr := 'DUBRJ11';
        Labo : ListeCartesToStr := 'labo';
        BU : ListeCartesToStr := 'BU';
        Accueil : ListeCartesToStr := 'accueil';
    end;
end;


end.

