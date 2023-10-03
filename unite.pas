Unit unite;


Interface

Const MAX = 50;

Type Enviro = Set of (Manoir, INSA);

Type ListesCartes = Set of (Colonel_Moutarde, Docteur_Olive, Madame_Pervenche, Mademoiselle_Rose, Madame_Leblanc, Poignard, Chandelier, Revolver, Corde, Matraque, Clef_Anglaise, Cuisine, Grand_Salon, Petit_Salon, Salle_a_manger, Bureau, Bibliotheque, Veranda, Studio, Hall);

Type Persos = Set of (Colonel_Moutarde, Docteur_Olive, Madame_Pervenche, Mademoiselle_Rose, Madame_Leblanc);

Type Coords = Array [1..2] of Integer;

Type Joueur = record
    enVie : Boolean;
	cartes : ListeCartes;
	pos : Coords;
	perso : Persos;
end;

Type ListeJoueurs = Array of Joueur;

type Salle = Set of Coords;

Type Plateau = record 
    grille : Array [0..MAX,0..MAX] of Integer;
    salles : Array [1..9] of Salle;
end;


Implementation


end.