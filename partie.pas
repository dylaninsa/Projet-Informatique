Unit partie;


Interface

uses unite, Crt, affichage;


procedure jeu(var etui : Array of ListeCartes; plat : Plateau; var joueurs : ListeJoueurs);
procedure tour(plat : Plateau; var etui : Array of ListeCartes; var joueurs : ListeJoueurs; var accusation : Boolean; j_actif : Integer);
procedure finPartie(joueurs : ListeJoueurs; accusation : Boolean; var j_actif : Integer; var etui : Array of ListeCartes);
{procedure quitterSauvegarder(joueurs:ListeJoueurs; plat:Plateau; var etui:Array of ListeCartes; var sauvegarde:File);}
procedure deplacement(var plat : Plateau; lancer : Integer; var joueurs : ListeJoueurs; j_actif : Integer);
procedure lancerDes(var lancer : Integer);
procedure faireHypothese(var joueurs : ListeJoueurs; var hypo : Array of ListeCartes);
procedure demandeJoueur(var hypo : Array of ListeCartes;joueurs : ListeJoueurs; j_actif : Integer);
procedure faireAccusation(var etui : Array of ListeCartes; var joueurs : ListeJoueurs; var accusation : Boolean; j_actif : Integer);
function estDansSalle(joueurs : ListeJoueurs; plat : Plateau; j_actif : Integer) : Boolean;
function estDansLaSalle(joueurs : ListeJoueurs; plat : Plateau; j_actif : Integer) : ListeCartes;
function joueursEnVie(joueurs : ListeJoueurs) : Integer;
function caseEstLibre(joueurs : ListeJoueurs; plat : Plateau; co : Coords) : Boolean;


Implementation


function joueursEnVie(joueurs : ListeJoueurs) : Integer;

var i : Integer;

begin
    {Renvoie le nombre de joueurs en vie}
    joueursEnVie := 0;
    for i := 0 to length(joueurs) do
        begin
            if (joueurs[i].enVie) then
                joueursEnVie := joueursEnVie + 1;
        end;
end;



procedure jeu(var etui : Array of ListeCartes; plat : Plateau; var joueurs : ListeJoueurs);

var j_actif : Integer;
    accusation : Boolean;
    key : Char;

begin
    {Lance le jeu}
    ClrScr;
    accusation := False;


    {Lance les tours pour chaque perso jusqu'à ce qu'on quitte ou qu'il n'y ait plus assez de joueurs en vie ou sir les éléments du meurtre ont été trouvés}
    j_actif := 1;
    repeat 
        begin 
            if (joueurs[j_actif].enVie) then
                tour(plat, etui, joueurs, accusation, j_actif);
            
            writeln('Appuyer sur ''Q'' pour quitter ou sur n''importe quelle autre touche pour continuer.');
            key := readKey();

            if (j_actif = length(joueurs)) then
                j_actif := 1
            else
                j_actif := j_actif + 1;
        
        end;
        until ((key = QUIT) OR accusation OR (joueursEnVie(joueurs) < 2));
    

    {Fini la partie}
    ClrScr;
    finPartie(joueurs, accusation, j_actif, etui);
end;



function estDansSalle(joueurs : ListeJoueurs; plat : Plateau; j_actif : Integer) : Boolean;

var co : Coords;
    i : Integer;

begin
    {Renvoie True si le joueur est dans une salle, False sinon}
    i := 1;
    estDansSalle := False;
    repeat
        begin
            for co in plat.salles[i].cases do
                begin
                    if ((co[1] = joueurs[j_actif].pos[1]) AND (co[2] = joueurs[j_actif].pos[2])) then
                        estDansSalle := True;
                end;
            i := i + 1;
        end;
        until ((i = 10) OR estDansSalle);        

end;



function estDansLaSalle(joueurs : ListeJoueurs; plat : Plateau; j_actif : Integer) : ListeCartes;

var co : Coords;
    i : Integer;

begin
    {Renvoie la salle dans laquelle le joueur se trouve}
    i := 1;
    repeat
        begin
            for co in plat.salles[i].cases do
                begin
                    if ((co[1] = joueurs[j_actif].pos[1]) AND (co[2] = joueurs[j_actif].pos[2])) then
                        estDansLaSalle := plat.salles[i].nom;
                end;
            i := i + 1;
        end;
        until (i = 10);        

end;



procedure tour(plat : Plateau; var etui : Array of ListeCartes; var joueurs : ListeJoueurs; var accusation : Boolean; j_actif : Integer);

var c, lancer : Integer;
    hypo : Array [1..3] of ListeCartes;
    continue : Char;

begin
    {Indique le personnage qui joue}
    ClrScr;
    writeln('C''est à ', joueurs[j_actif].perso, ' de jouer ! (Appuyer sur ''espace'')');
    repeat
        continue := readKey();
        until (continue = #32);


    {Affiche les cartes du joueurs qui joue}
    affichageCartes(joueurs, j_actif);
    writeln('(Appuyer sur ''espace'')');
    repeat
        continue := readKey();
        until (continue = #32);
    

    {Différentes action possibles selon les cas}
    if (estDansSalle(joueurs, plat, j_actif)) then
        begin
            writeln('Que voulez-vous faire :');
            writeln('   1 : Vous déplacer');
            writeln('   2 : Formuler une hypothèse'); 
            writeln('   3 : Formuler une accusation');  

            repeat
                write('Votre choix est : ');
                readln(c);
                if not((c >= 1) AND (c <= 3)) then
                    writeln('Ce choix n''est pas disponible.')
                until ((c >= 1) AND (c <= 3));


            case c of
                1 : begin
                        lancerDes(lancer);
                        deplacement(plat, lancer, joueurs, j_actif);
                        if (estDansSalle(joueurs, plat, j_actif)) then
                            begin
                                affichageCartes(joueurs, j_actif);
                                faireHypothese(joueurs, hypo);
                                demandeJoueur(hypo, joueurs, j_actif);
                            end;
                    end;
                2 : begin
                        affichageCartes(joueurs, j_actif);
                        faireHypothese(joueurs, hypo);
                        demandeJoueur(hypo, joueurs, j_actif);
                    end;
                3 : begin
                        faireAccusation(etui, joueurs, accusation, j_actif);
                    end;
            end;
        end
    else
        begin
            lancerDes(lancer);
            deplacement(plat, lancer, joueurs, j_actif);
            if (estDansSalle(joueurs, plat, j_actif)) then
                begin
                    affichageCartes(joueurs, j_actif);
                    faireHypothese(joueurs, hypo);
                    demandeJoueur(hypo, joueurs, j_actif);
                end;
        end;
end;



procedure deplacement(var plat : Plateau; lancer : Integer; var joueurs : ListeJoueurs; j_actif : Integer);

var key : Char;
	move, i : Integer;
    co : Coords;

begin
    {Affichage du plateau}
    move := lancer;
    affichagePlateau(plat, joueurs);
    affichageDeplacement(move);


    if estDansSalle(joueurs, plat, j_actif) then
        begin
            case estDansLaSalle(joueurs, plat, j_actif) of
                Cuisine : 
                        begin
                            repeat
                                key := readKey();
                                case key of 
                                    DOWN : 
                                        begin
                                            co[1] := 6;
                                            co[2] := 9;
                                            if (caseEstLibre(joueurs, plat, co)) then
                                                begin
                                                    affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                                    joueurs[j_actif].pos[1] := co[1];
                                                    joueurs[j_actif].pos[2] := co[2];
                                                    move := move - 1;
                                                    plat.salles[1].nb_j := plat.salles[1].nb_j - 1;
                                                end;
                                        end;
                                    UP : 
                                        begin
                                            co[1] := 20;
                                            co[2] := 23;
                                            affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                            joueurs[j_actif].pos[1] := co[1];
                                            joueurs[j_actif].pos[2] := co[2];
                                            move := move - 1;
                                            plat.salles[1].nb_j := plat.salles[1].nb_j - 1;
                                            plat.salles[8].nb_j := plat.salles[8].nb_j + 1;
                                        end;
                                end;
                                until ((key = DOWN) OR (key = UP));
                        end;
                Grand_Salon : 
                        begin

                            repeat
                                key := readKey();
                                case key of 
                                    DOWN : 
                                        begin
                                            co[1] := 11;
                                            co[2] := 10;
                                            if (caseEstLibre(joueurs, plat, co)) then
                                                begin
                                                    affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                                    joueurs[j_actif].pos[1] := co[1];
                                                    joueurs[j_actif].pos[2] := co[2];
                                                    move := move - 1;
                                                    plat.salles[2].nb_j := plat.salles[2].nb_j - 1;
                                                end;
                                        end;
                                    UP :
                                        begin
                                            co[1] := 16;
                                            co[2] := 10;
                                            if (caseEstLibre(joueurs, plat, co)) then
                                                begin
                                                    affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                                    joueurs[j_actif].pos[1] := co[1];
                                                    joueurs[j_actif].pos[2] := co[2];
                                                    move := move - 1;
                                                    plat.salles[2].nb_j := plat.salles[2].nb_j - 1;
                                                end;
                                        end;
                                    LEFT : 
                                        begin
                                            co[1] := 9;
                                            co[2] := 7;
                                            if (caseEstLibre(joueurs, plat, co)) then
                                                begin
                                                    affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                                    joueurs[j_actif].pos[1] := co[1];
                                                    joueurs[j_actif].pos[2] := co[2];
                                                    move := move - 1;
                                                    plat.salles[2].nb_j := plat.salles[2].nb_j - 1;
                                                end;
                                        end;
                                    RIGHT :
                                        begin
                                            co[1] := 18;
                                            co[2] := 7;
                                            if (caseEstLibre(joueurs, plat, co)) then
                                                begin
                                                    affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                                    joueurs[j_actif].pos[1] := co[1];
                                                    joueurs[j_actif].pos[2] := co[2];
                                                    move := move - 1;
                                                    plat.salles[2].nb_j := plat.salles[2].nb_j - 1;
                                                end;
                                        end;
                                end;
                                until ((key = DOWN) OR (key = UP) OR (key = LEFT) OR (key = RIGHT));
                        end;
                Petit_Salon : 
                        begin
                            repeat
                                key := readKey();
                                case key of 
                                    DOWN : 
                                        begin
                                            co[1] := 21;
                                            co[2] := 7;
                                            if (caseEstLibre(joueurs, plat, co)) then
                                                begin
                                                    affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                                    joueurs[j_actif].pos[1] := co[1];
                                                    joueurs[j_actif].pos[2] := co[2];
                                                    move := move - 1;
                                                    plat.salles[3].nb_j := plat.salles[3].nb_j - 1;
                                                end;
                                        end;
                                    UP : 
                                        begin
                                            co[1] := 7;
                                            co[2] := 21;
                                            affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                            joueurs[j_actif].pos[1] := co[1];
                                            joueurs[j_actif].pos[2] := co[2];
                                            move := move - 1;
                                            plat.salles[3].nb_j := plat.salles[3].nb_j - 1;
                                            plat.salles[7].nb_j := plat.salles[7].nb_j + 1;
                                        end;
                                end;
                                until ((key = DOWN) OR (key = UP));
                        end;
                Salle_a_manger : 
                        begin
                            repeat
                                key := readKey();
                                case key of 
                                    DOWN : 
                                        begin
                                            co[1] := 8;
                                            co[2] := 18;
                                            if (caseEstLibre(joueurs, plat, co)) then
                                                begin
                                                    affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                                    joueurs[j_actif].pos[1] := co[1];
                                                    joueurs[j_actif].pos[2] := co[2];
                                                    move := move - 1;
                                                    plat.salles[4].nb_j := plat.salles[4].nb_j - 1;
                                                end;
                                        end;
                                    RIGHT :
                                        begin
                                            co[1] := 10;
                                            co[2] := 14;
                                            if (caseEstLibre(joueurs, plat, co)) then
                                                begin
                                                    affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                                    joueurs[j_actif].pos[1] := co[1];
                                                    joueurs[j_actif].pos[2] := co[2];
                                                    move := move - 1;
                                                    plat.salles[4].nb_j := plat.salles[4].nb_j - 1;
                                                end;
                                        end;
                                end;
                                until ((key = DOWN) OR (key = RIGHT));
                        end;
                Bureau : 
                        begin
                            repeat
                                key := readKey();
                                case key of 
                                    DOWN : 
                                        begin
                                            co[1] := 24;
                                            co[2] := 15;
                                            if (caseEstLibre(joueurs, plat, co)) then
                                                begin
                                                    affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                                    joueurs[j_actif].pos[1] := co[1];
                                                    joueurs[j_actif].pos[2] := co[2];
                                                    move := move - 1;
                                                    plat.salles[5].nb_j := plat.salles[5].nb_j - 1;
                                                end;
                                        end;
                                    LEFT :
                                        begin
                                            co[1] := 19;
                                            co[2] := 11;
                                            if (caseEstLibre(joueurs, plat, co)) then
                                                begin
                                                    affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                                    joueurs[j_actif].pos[1] := co[1];
                                                    joueurs[j_actif].pos[2] := co[2];
                                                    move := move - 1;
                                                    plat.salles[5].nb_j := plat.salles[5].nb_j - 1;
                                                end;
                                        end;
                                end;
                                until ((key = DOWN) OR (key = RIGHT));
                        end;
                Bibliotheque : 
                        begin
                            repeat
                                key := readKey();
                                case key of 
                                    UP : 
                                        begin
                                            co[1] := 22;
                                            co[2] := 15;
                                            if (caseEstLibre(joueurs, plat, co)) then
                                                begin
                                                    affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                                    joueurs[j_actif].pos[1] := co[1];
                                                    joueurs[j_actif].pos[2] := co[2];
                                                    move := move - 1;
                                                    plat.salles[6].nb_j := plat.salles[6].nb_j - 1;
                                                end;
                                        end;
                                    LEFT :
                                        begin
                                            co[1] := 18;
                                            co[2] := 18;
                                            if (caseEstLibre(joueurs, plat, co)) then
                                                begin
                                                    affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                                    joueurs[j_actif].pos[1] := co[1];
                                                    joueurs[j_actif].pos[2] := co[2];
                                                    move := move - 1;
                                                    plat.salles[6].nb_j := plat.salles[6].nb_j - 1;
                                                end;
                                        end;
                                end;
                                until ((key = DOWN) OR (key = RIGHT));
                        end;
                Veranda : 
                        begin
                            repeat
                                key := readKey();
                                case key of 
                                    UP : 
                                        begin
                                            co[1] := 7;
                                            co[2] := 20;
                                            if (caseEstLibre(joueurs, plat, co)) then
                                                begin
                                                    affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                                    joueurs[j_actif].pos[1] := co[1];
                                                    joueurs[j_actif].pos[2] := co[2];
                                                    move := move - 1;
                                                    plat.salles[7].nb_j := plat.salles[7].nb_j - 1;
                                                end;
                                        end;
                                    DOWN : 
                                        begin
                                            co[1] := 21;
                                            co[2] := 6;
                                            affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                            joueurs[j_actif].pos[1] := co[1];
                                            joueurs[j_actif].pos[2] := co[2];
                                            move := move - 1;
                                            plat.salles[7].nb_j := plat.salles[7].nb_j - 1;
                                            plat.salles[3].nb_j := plat.salles[3].nb_j + 1;
                                        end;
                                end;
                                until ((key = DOWN) OR (key = UP));
                        end;
                Studio : 
                        begin
                            repeat
                                key := readKey();
                                case key of 
                                    UP : 
                                        begin
                                            co[1] := 20;
                                            co[2] := 22;
                                            if (caseEstLibre(joueurs, plat, co)) then
                                                begin
                                                    affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                                    joueurs[j_actif].pos[1] := co[1];
                                                    joueurs[j_actif].pos[2] := co[2];
                                                    move := move - 1;
                                                    plat.salles[8].nb_j := plat.salles[8].nb_j - 1;
                                                end;
                                        end;
                                    DOWN : 
                                        begin
                                            co[1] := 6;
                                            co[2] := 8;
                                            affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                            joueurs[j_actif].pos[1] := co[1];
                                            joueurs[j_actif].pos[2] := co[2];
                                            move := move - 1;
                                            plat.salles[8].nb_j := plat.salles[8].nb_j - 1;
                                            plat.salles[1].nb_j := plat.salles[1].nb_j + 1;
                                        end;
                                end;
                                until ((key = DOWN) OR (key = UP));
                        end;
                Hall : 
                        begin
                            repeat
                                key := readKey();
                                case key of 
                                    UP :
                                        begin
                                            co[1] := 14;
                                            co[2] := 19;
                                            if (caseEstLibre(joueurs, plat, co)) then
                                                begin
                                                    affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                                    joueurs[j_actif].pos[1] := co[1];
                                                    joueurs[j_actif].pos[2] := co[2];
                                                    move := move - 1;
                                                    plat.salles[9].nb_j := plat.salles[9].nb_j - 1;
                                                end;
                                        end;
                                    LEFT : 
                                        begin
                                            co[1] := 13;
                                            co[2] := 19;
                                            if (caseEstLibre(joueurs, plat, co)) then
                                                begin
                                                    affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                                    joueurs[j_actif].pos[1] := co[1];
                                                    joueurs[j_actif].pos[2] := co[2];
                                                    move := move - 1;
                                                    plat.salles[9].nb_j := plat.salles[9].nb_j - 1;
                                                end;
                                        end;
                                    RIGHT :
                                        begin
                                            co[1] := 17;
                                            co[2] := 22;
                                            if (caseEstLibre(joueurs, plat, co)) then
                                                begin
                                                    affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                                    joueurs[j_actif].pos[1] := co[1];
                                                    joueurs[j_actif].pos[2] := co[2];
                                                    move := move - 1;
                                                    plat.salles[9].nb_j := plat.salles[9].nb_j - 1;
                                                end;
                                        end;
                                end;
                                until ((key = DOWN) OR (key = UP) OR (key = LEFT) OR (key = RIGHT));
                        end;
            end;
        end;


    {Déplace le pion en vérifiant les conditions de case d'arrivée, et réduit le nombre de déplacement restant jusqu'à que les déplacements restants soient à 0 ou que le joueur soit dans une salle}
    if not(estDansSalle(joueurs, plat, j_actif)) then
        begin
            repeat
	        	begin
                    affichageDeplacement(move);
		        	affiche(joueurs[j_actif].pion, joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
		        	key := readKey();
		        	case key of
		        		UP : {Déplacement en haut}
                            begin
                                co[1] := joueurs[j_actif].pos[1];
                                co[2] := joueurs[j_actif].pos[2] - 1;
                                if ((joueurs[j_actif].pos[2] - 1 >= 2) AND (plat.grille[joueurs[j_actif].pos[1]][joueurs[j_actif].pos[2] - 1] <> 1) AND (caseEstLibre(joueurs, plat, co))) then 
				        	        begin
				        	        	affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                        joueurs[j_actif].pos[2] := joueurs[j_actif].pos[2] - 1;
                                        move := move - 1;
				        	        end;
                            end;
				        DOWN : {Déplacement en bas}
                            begin
                                co[1] := joueurs[j_actif].pos[1];
                                co[2] := joueurs[j_actif].pos[2] + 1;
                                if ((joueurs[j_actif].pos[2] + 1 <= 26) AND (plat.grille[joueurs[j_actif].pos[1]][joueurs[j_actif].pos[2] + 1] <> 1) AND (caseEstLibre(joueurs, plat, co))) then 
					                begin
					                	affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                        joueurs[j_actif].pos[2] := joueurs[j_actif].pos[2] + 1;
                                        move := move - 1;
					                end;
                            end;
				        LEFT : {Déplacement à gauche}
                            begin
                                co[1] := joueurs[j_actif].pos[1] - 1;
                                co[2] := joueurs[j_actif].pos[2];
                                if ((joueurs[j_actif].pos[1] - 1 >= 2) AND (plat.grille[joueurs[j_actif].pos[1] - 1][joueurs[j_actif].pos[2]] <> 1) AND (caseEstLibre(joueurs, plat, co))) then 
				        	        begin
				        	        	affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                        joueurs[j_actif].pos[1] := joueurs[j_actif].pos[1] - 1;
                                        move := move - 1;
                                    end;
				        	end;
				        RIGHT : {Déplacement à droite}
                            begin
                                co[1] := joueurs[j_actif].pos[1] + 1;
                                co[2] := joueurs[j_actif].pos[2];
                                if ((joueurs[j_actif].pos[1] + 1 <= 25) AND (plat.grille[joueurs[j_actif].pos[1] + 1][joueurs[j_actif].pos[2]] <> 1) AND (caseEstLibre(joueurs, plat, co))) then 
					                begin
					        	        affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
                                        joueurs[j_actif].pos[1] := joueurs[j_actif].pos[1] + 1;
                                        move := move - 1;
                                    end;
					        end;
                    end;
		        end;
		        until ((move = 0) OR estDansSalle(joueurs, plat, j_actif));


            {Ajout d'un joueur dans la salle}
            if estDansSalle(joueurs, plat, j_actif) then
                begin
                    for i := 1 to 9 do
                        if (plat.salles[i].nom = estDansLaSalle(joueurs, plat, j_actif)) then
                            plat.salles[i].nb_j := plat.salles[i].nb_j + 1;
                end;
        end;
        
    
    affiche(joueurs[j_actif].pion, joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
    affichageDeplacement(move);
    Delay(500);
    ClrScr;
end;



procedure lancerDes(var lancer : Integer);

var de1, de2 : Integer;
    continue : Char;

begin
    {Lance les 2 dés de manière aléatoire}
    Randomize;

    de1 := random(5) + 1;
    de2 := random(5) + 1;
    
    affichageDes(de1, de2);

    writeln('(Appuyer sur ''espace'')');

    repeat
        continue := readKey();
        until (continue = #32);

    lancer := de1 + de2;
end;



procedure faireHypothese(var joueurs : ListeJoueurs; var hypo : array of ListeCartes);

var g1, g2, g3 : ListeCartes;

begin 
    {Enregistre les éléments de l'hypothèse}
    writeln('Vous allez formuler une hypothèse !');

    write('Selon vous, qui pourrait-être l''assassin ? ');
    readln(g1);
    hypo[1] := g1;

    write('Selon vous, quelle pourrait-être l''arme du crime ? ');
    readln(g2);
    hypo[2] := g2;

    write('Selon vous, dans quelle salle l''assassinat aurait-il pu avoir lieu  ? ');
    readln(g3);
    hypo[3] := g3;
end;



procedure demandeJoueur(var hypo : array of ListeCartes; joueurs : ListeJoueurs; j_actif : Integer);

var i, j, k, l, nb : Integer;
    montrer : Boolean;
    commun : Array of ListeCartes;
    temp : set of ListeCartes;
    reveal, carte : ListeCartes;
    continue : Char;

begin
    {Demande aux joueurs suivants si il possède une des cartes de l'hypothèse formulée}
    i := 1;
    montrer := False;
    j := j_actif;


    {Répète la demande au joueur en stockant les cartes en commun entre le joueur j et l'hypothèse formulée jusqu'à ce qu'une carte coincide ou que tout les joueurs aient été interrogés}
    repeat 
        if (j + i > length(joueurs)) then
            j := (j + i) mod length(joueurs)
        else
            j := j + i;


        temp := [];
        for k := 1 to 3 do
            begin
                if (hypo[k] in joueurs[j].cartes) then
                    begin
                        Include(temp, hypo[k]);
                    end;
            end;


        if (temp <> []) then
            begin
                nb := 0;
                for carte in temp do
                    begin
                        nb := nb + 1;
                    end;
                
                SetLength(commun, nb);
                l := 1;
                for carte in temp do
                    begin
                        commun[l] := carte;
                        l := l + 1;
                    end;

                affichageMontrerCartes(commun, joueurs, j, reveal);
                montrer := True;
                SetLength(commun, 0);
            end
        else
            begin
                writeln(joueurs[j].perso, ' n''as aucune des cartes de votre hypothèse.');
                Delay(500);
            end;

        
        i := i + 1;
        until (montrer OR (i = length(joueurs)));


    {Affiche au joueur du tour la carte d'un des joueurs coincidant avec l'hypothèse formulée, si elle existe}
    if (montrer) then
        begin
            ClrScr;
            writeln(joueurs[j_actif].perso, ', ', joueurs[j].perso, ' vous montre une de ses cartes. Êtes-vous prêt ?  (Appuyer sur ''espace'')');
            repeat
                continue := readKey();
                until (continue = #32);
            writeln('La carte que ', joueurs[j].perso, ' vous montre est : ', reveal, '(Appuyer sur ''espace'')');
            repeat
                continue := readKey();
                until (continue = #32);
            ClrScr;
        end
    else
        writeln('Aucun des joueurs de cette partie ne possède une carte de votre hypothèse !');
end;



procedure faireAccusation(var etui : Array of ListeCartes; var joueurs : ListeJoueurs; var accusation : Boolean; j_actif : Integer);

var guess : Array [1..3] of ListeCartes;
    g1, g2, g3, carte : ListeCartes;

begin 
    {Enregistre les éléments de l'accusation}
    writeln('Vous allez formuler une accusation !');

    write('Selon vous, qui est l''assassin ? ');
    readln(g1);
    guess[1] := g1;

    write('Selon vous, quelle est l''arme du crime ? ');
    readln(g2);
    guess[2] := g2;

    write('Selon vous, dans quelle salle l''assassinat a-t-il eu lieu  ? ');
    readln(g3);
    guess[3] := g3;


    {Tests : Boolean vérifiant que l'accusation et l'étui coincident > Il ne les compare pas donc erreurs sur le if d'après
    for carte in etui do write(carte, ' ');
    writeln();
    for carte in guess do write(carte, ' ');
    writeln();
    writeln((etui[1] = guess[1]));
    writeln((etui[2] = guess[2]));
    writeln((etui[3] = guess[3]));
    writeln((etui[1] = guess[1]) AND (etui[2] = guess[2]) AND (etui[3] = guess[3]));
    Delay(5000);}


    {Vérifie que l'accusation et l'étui coincident, sinon le joueur du tour meurt}
    if ((etui[1] = guess[1]) AND (etui[2] = guess[2]) AND (etui[3] = guess[3])) then
        accusation := True
    else
        joueurs[j_actif].enVie := False;
end;



procedure finPartie(joueurs : ListeJoueurs; accusation : Boolean; var j_actif : Integer; var etui : Array of ListeCartes);

begin
    {Si l'accusation est vérifiée alors affiche le gagnant, sinon annonce affiche la défaite de tous}
    if accusation then
        begin
            if (j_actif - 1 = 0) then
                j_actif := length(joueurs)
            else
                j_actif := j_actif - 1;
    
            writeln('La partie est terminée ! Un enquêteur a trouvé le meurtrier, l''arme du crime et le lieu de l''assassinnat.');
            writeln('Et cet en enquêteur est ', joueurs[j_actif].perso, ' !');
            writeln('Voici les éléments du meurtre : ', etui[1], ' ', etui[2], ' ', etui[3], '.')
        end
    else
        begin
            writeln('Aucun des enquêteurs n''est parvenu à résoudre ce meurtre. La partie est finie.');
            writeln('Voici les éléments du meurtre : ', etui[1], ' ', etui[2], ' ', etui[3], '.');
        end;
end;



function caseEstLibre(joueurs : ListeJoueurs; plat : Plateau; co : Coords) : Boolean;

var i : Integer;

begin
    {Renvoie True si la case est libre, False sinon}
    caseEstLibre := True;
    for i := 1 to length(joueurs) do
        begin
            if ((co[1] = joueurs[i].pos[1]) AND (co[2] = joueurs[i].pos[2])) then
                caseEstLibre := False;
        end;
end;



{procedure quitterSauvegarder(joueurs : ListeJoueurs; plat : Plateau; var etui : Array of ListeCartes; var sauvegarde : File);}

end.