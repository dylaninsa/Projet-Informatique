Unit unite;


Interface

Const 
    MAX = 50;
    UP = #72;
	DOWN = #80;
	LEFT = #75;
	RIGHT = #77;
    QUIT = #113;

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
    nb_j : Integer;
end;

Type Plateau = record 
    grille : Array [1..MAX,1..MAX] of Integer;
    salles : Array [1..10] of Salle;
end;


Implementation


end.
