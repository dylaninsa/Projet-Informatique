Unit partie;


Interface


uses unite, Crt, affichage, sysutils;


procedure jeu(var etui : Array of ListeCartes; plat : Plateau; var joueurs : ListeJoueurs; environnement : Enviro; var j_actif : Integer);
procedure tour(plat : Plateau; var etui : Array of ListeCartes; var joueurs : ListeJoueurs; var accusation : Boolean; j_actif : Integer; environnement : Enviro);
procedure lancerDes(var lancer : Integer);
procedure deplacement(plat : Plateau; lancer : Integer; var joueurs : ListeJoueurs; j_actif : Integer);
procedure placementSalle(var joueurs : ListeJoueurs; plat : Plateau; j_actif : Integer);
procedure faireHypothese(var joueurs : ListeJoueurs; var hypo : array of ListeCartes; plat : Plateau; j_actif : Integer; environnement : Enviro);
procedure faireAccusation(var etui : Array of ListeCartes; var joueurs : ListeJoueurs; var accusation : Boolean; j_actif : Integer; environnement : Enviro; plat : Plateau);
procedure finPartie(joueurs : ListeJoueurs; accusation : Boolean; var j_actif : Integer; var etui : Array of ListeCartes);
procedure quitterSauvegarder(var joueurs : ListeJoueurs; var etui : Array of ListeCartes; j_actif : Integer; environnement : Enviro);
function estDansLaSalle(plat : Plateau; coordonnees : Coords) : Integer;
function joueursEnVie(joueurs : ListeJoueurs) : Integer;
function caseEstLibre(joueurs : ListeJoueurs; plat : Plateau; co : Coords) : Boolean;
function sortieSallePossible(joueurs : ListeJoueurs; plat : Plateau; j_actif : Integer) : Boolean;



Implementation


procedure jeu(var etui : Array of ListeCartes; plat : Plateau; var joueurs : ListeJoueurs; environnement : Enviro; var j_actif : Integer);
{Procédure principale du programme un fois qu'une partie est lancée
Elle va lancer les tours un par un, et ce pour pour chaque joueur
Le programme s'arrête lorsque l'on quitte manuellement ou lorsque la partie se termine}

var accusation : Boolean;
    key : Char;

begin
    ClrScr;  // Le terminal est nettoyé
    accusation := False;  // Boolean qui vaut False le temps que l'enquête n'as pas ete résolue

    {Lance les tours pour chaque joueur jusqu'à ce que l'on quitte ou qu'il n'y ait plus assez de joueurs en vie ou que les éléments du meurtre aient été trouvés}
    repeat 
        if (joueurs[j_actif].enVie) then
            tour(plat, etui, joueurs, accusation, j_actif, environnement);  // Lance le tour du joueur 'actif' si il est en vie
            

        {Vérifie si la partie est finie}
        if ((joueursEnVie(joueurs) < 1) OR (accusation)) then  // Si la partie est finie, le procédure finPartie est appelé
            begin
                ClrScr;  // Le terminal est nettoyé
                finPartie(joueurs, accusation, j_actif, etui);  
            end
        else
            {Sinon le joueur 'actif' est maintenant le joueur suivant}
            begin
                if (j_actif = length(joueurs)) then  // Si le dernier joueur à avoir joué est le dernier de la liste de joueurs, le joueur 'actif' devient le permier de la liste
                    j_actif := 1  
                else  // Sinon, c'est le joueur suivant qui devient le joueur 'actif'
                    j_actif := j_actif + 1;  


                writeln('Appuyer sur ''Q'' pour quitter ou sur n''importe quelle autre touche pour continuer.');  // Si la touche 'Q' est pressée, la partie s'arrête, sinon le tour d'après est lancé
                key := readKey();
            end;


        if (key = QUIT) then
            quitterSauvegarder(joueurs, etui, j_actif, environnement);  // Quitte la partie si 'Q' est pressée

        until ((key = QUIT) OR (joueursEnVie(joueurs) < 1) OR (accusation));  // La partie continue le temps que 'Q' n'est pas pressée, qu'il y a au moins un joueur en vie et que l'accusation n'ait pas été découverte

    ClrScr;
end;



procedure tour(plat : Plateau; var etui : Array of ListeCartes; var joueurs : ListeJoueurs; var accusation : Boolean; j_actif : Integer; environnement : Enviro);
{Procedure centrale qui présente les différentes actions possibles au joueur 'actif' et qui appelle les procédures selon le choix du joueur}

var c, lancer : Integer;
    hypo : Array [1..3] of ListeCartes;
    continue : Char;

begin
    ClrScr;  // Le terminal est nettoyé

    {Indique le joueur qui va jouer}
    write('C''est a ');
    colorPerso(joueurs, j_actif);  // Appel de la procédure pour la coloration de l'encre pour l'écriture du nom du personnage
    write(joueurs[j_actif].perso);
    TextColor(15);  // Rétablie la couleur de l'encre d'origine : blanc
    writeln(' de jouer ! (Appuyer sur ''espace'')');

    repeat  // Boucle s'assurant que le joueur 'actif' soit prêt à jouer en appuyant sur 'espcace'
        continue := readKey();
        until (continue = SPACE);   


    affichageCartes(joueurs, j_actif);  // Appel de la procédure permettant d'afficher les cartes du joueur 'actif'


    if (estDansLaSalle(plat, joueurs[j_actif].pos) <> 0) then  // Affiche la salle dans laquelle le joueur 'actif' se trouve, si il est dans une salle
        writeln('Vous etes actuellement dans la salle : ', plat.salles[estDansLaSalle(plat, joueurs[j_actif].pos)].nom, '.');
    writeln('(Appuyer sur ''espace'')');

    repeat  // Boucle s'assurant que le joueur 'actif' ai prit connaissance de ses cartes et de la salle dans laquelle il se trouve en appuyant sur 'espcace'
        continue := readKey();
        until (continue = SPACE);
    
    case estDansLaSalle(plat, joueurs[j_actif].pos) of
        0 : // Le joueur 'actif' n'est dans aucune salle au début du tour
            begin  
                lancerDes(lancer);  // Appel de la procedure lancerDes qui va définir le nombre de déplacement possible du joueur 'actif' pour le tour actuel
                deplacement(plat, lancer, joueurs, j_actif);  // Appel de la procedure deplacement permettant au joueur 'actif' de se déplacer sur le plateau de jeu
                if (estDansLaSalle(plat, joueurs[j_actif].pos) <> 0) then  // Vérification de la présence du joueur 'actif' dans une salle
                    begin
                        if (estDansLaSalle(plat, joueurs[j_actif].pos) <> 10) then  // Si le joueur 'actif' est dans une salle différente de la salle pour formuler un accusation
                            faireHypothese(joueurs, hypo, plat, j_actif, environnement)  // Appel de la procedure faireHypothese pour formuler une hypothèse
                        else  // Sinon
                            faireAccusation(etui, joueurs, accusation, j_actif, environnement, plat);  // Appel de la procedure faireAccusation pour formuler une accusation
                    end;
            end;
        1..9 :  // Le joueur 'actif' est dans une salle différente de la salle d'accusation au début du tour
            begin
                if sortieSallePossible(joueurs, plat, j_actif) then  // Vérifie si le joueur 'actif' peut sortir de la salle dans laquelle il se trouve
                    begin
                        {Propose au joueur 'actif' les actions possibles}
                        writeln('Que voulez-vous faire :');
                        writeln('   1 : Vous deplacer');
                        writeln('   2 : Formuler une hypothese'); 

                        {Lecture du choix d'action du joueur 'actif' et vérification que l'action soit possible}
                        repeat
                            write('Votre choix est : ');
                            readln(c);
                            if not((c >= 1) AND (c <= 2)) then
                                writeln('Ce choix est invalide.')
                            until ((c >= 1) AND (c <= 2));

                        {Lance les action en fonction du choix du joueur 'actif'}
                        case c of
                            1 : begin  // Choix : déplacement
                                    lancerDes(lancer);  // Appel de la procedure lancerDes qui va définir le nombre de déplacement possible du joueur 'actif' pour le tour actuel
                                    deplacement(plat, lancer, joueurs, j_actif);  // Appel de la procedure deplacement permettant au joueur 'actif' de se déplacer sur le plateau de jeu
                                    if (estDansLaSalle(plat, joueurs[j_actif].pos) <> 0) then  // Vérification de la présence du joueur 'actif' dans une salle
                                        begin
                                            if (estDansLaSalle(plat, joueurs[j_actif].pos) <> 10) then  // Si le joueur 'actif' est dans une salle différente de la salle pour formuler un accusation
                                                faireHypothese(joueurs, hypo, plat, j_actif, environnement)  // Appel de la procedure faireHypothese pour formuler une hypothèse
                                            else  // Sinon
                                                faireAccusation(etui, joueurs, accusation, j_actif, environnement, plat);  // Appel de la procedure faireAccusation pour formuler une accusation
                                        end;
                                end;
                            2 : begin  // Choix : Formulation d'hypothèse
                                    faireHypothese(joueurs, hypo, plat, j_actif, environnement);  // Appel de la procedure faireHypothese pour formuler une hypothèse
                                end;
                        end;
                    end
                else  // Si le joueur 'actif' ne peut pas sortir de la salle
                    begin
                        writeln('Vous ne pouvez pas sortir de cette salle actuellement. Vous allez donc formuler une hypothèse. (Appuyer sur ''espace'')');
                        repeat  // Boucle s'assurant que le joueur 'actif' ai prit connaissance de la situation en appuyant sur 'espcace'
                            continue := readKey();
                            until (continue = SPACE);
                        faireHypothese(joueurs, hypo, plat, j_actif, environnement);  // Appel de la procedure faireHypothese pour formuler une hypothèse
                    end;
            end;
        10 :  // Le joueur 'actif' est dans la salle d'accusation au début du tour
            begin
                if sortieSallePossible(joueurs, plat, j_actif) then  // Vérifie si le joueur 'actif' peut sortir de la salle dans laquelle il se trouve
                    begin
                        {Propose au joueur 'actif' les actions possibles}
                        writeln('Que voulez-vous faire :');
                        writeln('   1 : Vous deplacer');
                        writeln('   2 : Formuler une accusation'); 

                        {Lecture du choix d'action du joueur 'actif' et vérification que l'action soit possible}
                        repeat
                            write('Votre choix est : ');
                            readln(c);
                            if not((c >= 1) AND (c <= 2)) then
                                writeln('Ce choix est invalide.')
                            until ((c >= 1) AND (c <= 2));

                        {Lance les action en fonction du choix du joueur 'actif'}
                        case c of
                            1 : begin  // Choix : déplacement
                                    lancerDes(lancer);  // Appel de la procedure lancerDes qui va définir le nombre de déplacement possible du joueur 'actif' pour le tour actuel
                                    deplacement(plat, lancer, joueurs, j_actif);  // Appel de la procedure deplacement permettant au joueur 'actif' de se déplacer sur le plateau de jeu
                                    if (estDansLaSalle(plat, joueurs[j_actif].pos) <> 0) then  // Vérification de la présence du joueur 'actif' dans une salle
                                        begin
                                            if (estDansLaSalle(plat, joueurs[j_actif].pos) <> 10) then  // Si le joueur 'actif' est dans une salle différente de la salle pour formuler un accusation
                                                faireHypothese(joueurs, hypo, plat, j_actif, environnement)  // Appel de la procedure faireHypothese pour formuler une hypothèse
                                            else  // Sinon
                                                faireAccusation(etui, joueurs, accusation, j_actif, environnement, plat);  // Appel de la procedure faireAccusation pour formuler une accusation
                                        end;
                                end;
                            2 : begin  // Choix : Formulation d'une accisation
                                    faireAccusation(etui, joueurs, accusation, j_actif, environnement, plat);  // Appel de la procedure faireAccusation pour formuler une accusation
                                end;
                        end;
                    end
                else  // Si le joueur 'actif' ne peut pas sortir de la salle
                    begin
                        writeln('Vous ne pouvez pas sortir de cette salle actuellement. Vous allez donc formuler une accusation. (Appuyer sur ''espace'')');
                        repeat  // Boucle s'assurant que le joueur 'actif' ai prit connaissance de la situation en appuyant sur 'espcace'
                            continue := readKey();
                            until (continue = SPACE);
                        faireAccusation(etui, joueurs, accusation, j_actif, environnement, plat);  // Appel de la procedure faireAccusation pour formuler une accusation
                    end;
            end;
    end;
end;



    



procedure lancerDes(var lancer : Integer);
{Procedure permettant de jeter virtuellement deux dés, et la valeur de la somme de ces deux derniers correspond au nombre de déplacement disponible}

var de1, de2 : Integer;
    continue : Char;

begin
    Randomize;  // Appel de la procédure Randomize afin de pouvoir uiliser la fonction random

    de1 := random(5) + 1;  // de1 prend une valeur aléatoire tirée entre 1 et 6
    de2 := random(5) + 1;  // de2 prend une valeur aléatoire tirée entre 1 et 6

    lancer := de1 + de2;  // lancer est donc la somme des deux dés

	writeln('Le premier de a pour valeur ', de1, ' et le second ', de2, '. Le nombre de deplacement total est donc de ', lancer, '.'); // Affiche la valeur des deux dés ainsi que le nombre de déplacements total
    writeln('(Appuyer sur ''espace'')');

    repeat  // Boucle s'assurant que le joueur 'actif' ai prit connaissance du nombre de déplacement qu'il possède en appuyant sur 'espcace'
        continue := readKey();
        until (continue = SPACE);
end;



procedure deplacement(plat : Plateau; lancer : Integer; var joueurs : ListeJoueurs; j_actif : Integer);
{Procedure permettant au joueur 'actif' de se déplacer sur le plateau de jeu}

var key : Char;
	move : Integer;
    co : Coords;
    bouge : Boolean;
    salle_act : Integer;

begin
    {Affichage du plateau}
    move := lancer;  // move est la variable qui compte le nombre de déplacements restants
    bouge := False;  // Boolean permettant de savoir si le joueur 'actif' est sorti de la salle dans laquelle il se trouve au début du tour, si il se trouve dans l'une d'elle
    affichagePlateau(plat, joueurs);  // Appel de la procedure affichant le plateau de jeu
    affichageDeplacement(move);  // Appel de la procedure affichant le nombre de déplacements restants


    if (estDansLaSalle(plat, joueurs[j_actif].pos) <> 0) then  // Vérification de la présence du joueur 'actif' dans une salle
        begin
            case estDansLaSalle(plat, joueurs[j_actif].pos) of  // Instruction permettant de traiter les différents cas en fonction des valeurs de la salle dans laquelle le joueur 'actif' se trouve
                1 :  // Le joueur 'actif' se trouve dans la salle 1
                    begin
                        affichageSortieSalle(1);  // Appel de la procedure affichageSortieSalle affichant les touches sur lesquelles appuyer pour sortir de cette salle
                        salle_act := 1;  // Variable stockant la valeur de salle dans laquelle le joueur 'actif' se trouve au début du tour
                        repeat  // Boucle se répétant tant que le joueur 'actif' n'est pas sortie de la salle dans laquelle il se trouve
                            key := readKey();  // Variable stockant la touche sur laquelle le joueur 'actif' a appuyé
                            case key of  // Instruction permettant de traiter les différents cas en fonction de la touche sur laquelle laa joueur 'actif' a appuyé
                                DOWN :  // Le joueur 'actif' a appuyé sur la flèche du bas 
                                    begin
                                        co[1] := 6;  // Coordonnées de la sortie correspondant à la touche flèche du bas
                                        co[2] := 9;
                                        if (caseEstLibre(joueurs, plat, co)) then  // Vérification de l'absence d'autre joueur sur la case sur laquelle le joueur 'actif' veut sortir. Si la condition est vraie, le joueur 'actif' va sortir de la salle
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                                joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;  // Diminition du nombre de déplacements restants
                                                bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                            end;
                                    end;
                                UP :  // Le joueur 'actif' a appuyé sur la flèche du haut. Dans ce cas, on n'a pas besoin de vérifier que la case est libre puisqu'il s'agit d'un passage secret que mène directement à une salle
                                    begin
                                        co[1] := 20;  // Coordonnées de la sortie correspondant à la touche flèche du haut
                                        co[2] := 23;
                                        affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                        joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                        joueurs[j_actif].pos[2] := co[2];
                                        move := move - 1;  // Diminition du nombre de déplacements restants
                                        bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                    end;
                            end;
                            until (bouge);
                    end;
                2 :  // Le joueur 'actif' se trouve dans la salle 2
                    begin
                        affichageSortieSalle(2);  // Appel de la procedure affichageSortieSalle affichant les touches sur lesquelles appuyer pour sortir de cette salle
                        salle_act := 2;  // Variable stockant la valeur de salle dans laquelle le joueur 'actif' se trouve au début du tour
                        repeat  // Boucle se répétant tant que le joueur 'actif' n'est pas sortie de la salle dans laquelle il se trouve
                            key := readKey();  // Variable stockant la touche sur laquelle le joueur 'actif' a appuyé
                            case key of   // Instruction permettant de traiter les différents cas en fonction de la touche sur laquelle laa joueur 'actif' a appuyé
                                DOWN :  // Le joueur 'actif' a appuyé sur la flèche du bas 
                                    begin
                                        co[1] := 11;  // Coordonnées de la sortie correspondant à la touche flèche du bas
                                        co[2] := 10;
                                        if (caseEstLibre(joueurs, plat, co)) then  // Vérification de l'absence d'autre joueur sur la case sur laquelle le joueur 'actif' veut sortir. Si la condition est vraie, le joueur 'actif' va sortir de la salle
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                                joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;  // Diminition du nombre de déplacements restants
                                                bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                            end;
                                    end;
                                UP :  // Le joueur 'actif' a appuyé sur la flèche du haut
                                    begin
                                        co[1] := 16;  // Coordonnées de la sortie correspondant à la touche flèche du haut
                                        co[2] := 10;
                                        if (caseEstLibre(joueurs, plat, co)) then  // Vérification de l'absence d'autre joueur sur la case sur laquelle le joueur 'actif' veut sortir. Si la condition est vraie, le joueur 'actif' va sortir de la salle
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                                joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;  // Diminition du nombre de déplacements restants
                                                bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                            end;
                                    end;
                                LEFT :  // Le joueur 'actif' a appuyé sur la flèche de gauche
                                    begin
                                        co[1] := 9;  // Coordonnées de la sortie correspondant à la touche flèche de gauche
                                        co[2] := 7;
                                        if (caseEstLibre(joueurs, plat, co)) then  // Vérification de l'absence d'autre joueur sur la case sur laquelle le joueur 'actif' veut sortir. Si la condition est vraie, le joueur 'actif' va sortir de la salle
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                                joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;  // Diminition du nombre de déplacements restants
                                                bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                            end;
                                    end;
                                RIGHT :  // Le joueur 'actif' a appuyé sur la flèche de droite
                                    begin
                                        co[1] := 18;  // Coordonnées de la sortie correspondant à la touche flèche de droite
                                        co[2] := 7;
                                        if (caseEstLibre(joueurs, plat, co)) then  // Vérification de l'absence d'autre joueur sur la case sur laquelle le joueur 'actif' veut sortir. Si la condition est vraie, le joueur 'actif' va sortir de la salle
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                                joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;  // Diminition du nombre de déplacements restants
                                                bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                            end;
                                    end;
                            end;
                            until (bouge);
                    end;
                3 :  // Le joueur 'actif' se trouve dans la salle 3
                    begin
                        affichageSortieSalle(3);  // Appel de la procedure affichageSortieSalle affichant les touches sur lesquelles appuyer pour sortir de cette salle
                        salle_act := 3;  // Variable stockant la valeur de salle dans laquelle le joueur 'actif' se trouve au début du tour
                        repeat  // Boucle se répétant tant que le joueur 'actif' n'est pas sortie de la salle dans laquelle il se trouve
                            key := readKey();  // Variable stockant la touche sur laquelle le joueur 'actif' a appuyé
                            case key of   // Instruction permettant de traiter les différents cas en fonction de la touche sur laquelle laa joueur 'actif' a appuyé
                                DOWN :  // Le joueur 'actif' a appuyé sur la flèche du bas 
                                    begin
                                        co[1] := 21;  // Coordonnées de la sortie correspondant à la touche flèche du bas
                                        co[2] := 7;
                                        if (caseEstLibre(joueurs, plat, co)) then  // Vérification de l'absence d'autre joueur sur la case sur laquelle le joueur 'actif' veut sortir. Si la condition est vraie, le joueur 'actif' va sortir de la salle
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                                joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;  // Diminition du nombre de déplacements restants
                                                bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                            end;
                                    end;
                                UP :  // Le joueur 'actif' a appuyé sur la flèche du haut. Dans ce cas, on n'a pas besoin de vérifier que la case est libre puisqu'il s'agit d'un passage secret que mène directement à une salle
                                    begin
                                        co[1] := 7;  // Coordonnées de la sortie correspondant à la touche flèche du haut
                                        co[2] := 21;
                                        affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                        joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                        joueurs[j_actif].pos[2] := co[2];
                                        move := move - 1;  // Diminition du nombre de déplacements restants
                                        bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                    end;
                            end;
                            until (bouge);
                    end;
                4 :  // Le joueur 'actif' se trouve dans la salle 4
                    begin
                        affichageSortieSalle(4);  // Appel de la procedure affichageSortieSalle affichant les touches sur lesquelles appuyer pour sortir de cette salle
                        salle_act := 4;  // Variable stockant la valeur de salle dans laquelle le joueur 'actif' se trouve au début du tour
                        repeat  // Boucle se répétant tant que le joueur 'actif' n'est pas sortie de la salle dans laquelle il se trouve
                            key := readKey();  // Variable stockant la touche sur laquelle le joueur 'actif' a appuyé
                            case key of  // Instruction permettant de traiter les différents cas en fonction de la touche sur laquelle laa joueur 'actif' a appuyé
                                DOWN :  // Le joueur 'actif' a appuyé sur la flèche du bas 
                                    begin
                                        co[1] := 8;  // Coordonnées de la sortie correspondant à la touche flèche du bas
                                        co[2] := 18;
                                        if (caseEstLibre(joueurs, plat, co)) then  // Vérification de l'absence d'autre joueur sur la case sur laquelle le joueur 'actif' veut sortir. Si la condition est vraie, le joueur 'actif' va sortir de la salle
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                                joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;  // Diminition du nombre de déplacements restants
                                                bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                            end;
                                    end;
                                RIGHT :  // Le joueur 'actif' a appuyé sur la flèche de droite
                                    begin
                                        co[1] := 10;  // Coordonnées de la sortie correspondant à la touche flèche de droite
                                        co[2] := 14;
                                        if (caseEstLibre(joueurs, plat, co)) then  // Vérification de l'absence d'autre joueur sur la case sur laquelle le joueur 'actif' veut sortir. Si la condition est vraie, le joueur 'actif' va sortir de la salle
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                                joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;  // Diminition du nombre de déplacements restants
                                                bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                            end;
                                    end;
                            end;
                            until (bouge);
                    end;
                5 :  // Le joueur 'actif' se trouve dans la salle 5
                    begin
                        affichageSortieSalle(5);  // Appel de la procedure affichageSortieSalle affichant les touches sur lesquelles appuyer pour sortir de cette salle
                        salle_act := 5;  // Variable stockant la valeur de salle dans laquelle le joueur 'actif' se trouve au début du tour
                        repeat  // Boucle se répétant tant que le joueur 'actif' n'est pas sortie de la salle dans laquelle il se trouve
                            key := readKey();  // Variable stockant la touche sur laquelle le joueur 'actif' a appuyé
                            case key of  // Instruction permettant de traiter les différents cas en fonction de la touche sur laquelle laa joueur 'actif' a appuyé
                                DOWN :  // Le joueur 'actif' a appuyé sur la flèche du bas 
                                    begin
                                        co[1] := 24;  // Coordonnées de la sortie correspondant à la touche flèche du bas
                                        co[2] := 15;
                                        if (caseEstLibre(joueurs, plat, co)) then  // Vérification de l'absence d'autre joueur sur la case sur laquelle le joueur 'actif' veut sortir. Si la condition est vraie, le joueur 'actif' va sortir de la salle
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                                joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;  // Diminition du nombre de déplacements restants
                                                bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                            end;
                                    end;
                                LEFT :  // Le joueur 'actif' a appuyé sur la flèche de gauche
                                    begin
                                        co[1] := 19;  // Coordonnées de la sortie correspondant à la touche flèche de gauche
                                        co[2] := 11;
                                        if (caseEstLibre(joueurs, plat, co)) then  // Vérification de l'absence d'autre joueur sur la case sur laquelle le joueur 'actif' veut sortir. Si la condition est vraie, le joueur 'actif' va sortir de la salle
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                                joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;  // Diminition du nombre de déplacements restants
                                                bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                            end;
                                    end;
                            end;
                            until (bouge);
                    end;
                6 :  // Le joueur 'actif' se trouve dans la salle 6
                    begin
                        affichageSortieSalle(6);  // Appel de la procedure affichageSortieSalle affichant les touches sur lesquelles appuyer pour sortir de cette salle
                        salle_act := 6;  // Variable stockant la valeur de salle dans laquelle le joueur 'actif' se trouve au début du tour
                        repeat  // Boucle se répétant tant que le joueur 'actif' n'est pas sortie de la salle dans laquelle il se trouve
                            key := readKey();  // Variable stockant la touche sur laquelle le joueur 'actif' a appuyé
                            case key of  // Instruction permettant de traiter les différents cas en fonction de la touche sur laquelle laa joueur 'actif' a appuyé 
                                UP :  // Le joueur 'actif' a appuyé sur la flèche du haut
                                    begin
                                        co[1] := 22;  // Coordonnées de la sortie correspondant à la touche flèche du haut
                                        co[2] := 15;
                                        if (caseEstLibre(joueurs, plat, co)) then  // Vérification de l'absence d'autre joueur sur la case sur laquelle le joueur 'actif' veut sortir. Si la condition est vraie, le joueur 'actif' va sortir de la salle
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                                joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;  // Diminition du nombre de déplacements restants
                                                bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                            end;
                                    end;
                                LEFT :  // Le joueur 'actif' a appuyé sur la flèche de gauche
                                    begin
                                        co[1] := 18;  // Coordonnées de la sortie correspondant à la touche flèche de gauche
                                        co[2] := 18;
                                        if (caseEstLibre(joueurs, plat, co)) then  // Vérification de l'absence d'autre joueur sur la case sur laquelle le joueur 'actif' veut sortir. Si la condition est vraie, le joueur 'actif' va sortir de la salle
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                                joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;  // Diminition du nombre de déplacements restants
                                                bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                            end;
                                    end;
                            end;
                            until (bouge);
                    end;
                7 :  // Le joueur 'actif' se trouve dans la salle 7
                    begin
                        affichageSortieSalle(7);  // Appel de la procedure affichageSortieSalle affichant les touches sur lesquelles appuyer pour sortir de cette salle
                        salle_act := 7;  // Variable stockant la valeur de salle dans laquelle le joueur 'actif' se trouve au début du tour
                        repeat  // Boucle se répétant tant que le joueur 'actif' n'est pas sortie de la salle dans laquelle il se trouve
                            key := readKey();  // Variable stockant la touche sur laquelle le joueur 'actif' a appuyé
                            case key of  // Instruction permettant de traiter les différents cas en fonction de la touche sur laquelle laa joueur 'actif' a appuyé 
                                UP :  // Le joueur 'actif' a appuyé sur la flèche du haut
                                    begin
                                        co[1] := 7;  // Coordonnées de la sortie correspondant à la touche flèche du haut
                                        co[2] := 20;
                                        if (caseEstLibre(joueurs, plat, co)) then  // Vérification de l'absence d'autre joueur sur la case sur laquelle le joueur 'actif' veut sortir. Si la condition est vraie, le joueur 'actif' va sortir de la salle
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                                joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;  // Diminition du nombre de déplacements restants
                                                bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                            end;
                                    end;
                                DOWN :  // Le joueur 'actif' a appuyé sur la flèche du bas. Dans ce cas, on n'a pas besoin de vérifier que la case est libre puisqu'il s'agit d'un passage secret que mène directement à une salle
                                    begin
                                        co[1] := 21;  // Coordonnées de la sortie correspondant à la touche flèche du bas
                                        co[2] := 6;
                                        affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                        joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                        joueurs[j_actif].pos[2] := co[2];
                                        move := move - 1;  // Diminition du nombre de déplacements restants
                                        bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                    end;
                            end;
                            until (bouge);
                    end;
                8 :  // Le joueur 'actif' se trouve dans la salle 8
                    begin 
                        affichageSortieSalle(8);  // Appel de la procedure affichageSortieSalle affichant les touches sur lesquelles appuyer pour sortir de cette salle
                        salle_act := 8;  // Variable stockant la valeur de salle dans laquelle le joueur 'actif' se trouve au début du tour
                        repeat  // Boucle se répétant tant que le joueur 'actif' n'est pas sortie de la salle dans laquelle il se trouve
                            key := readKey();  // Variable stockant la touche sur laquelle le joueur 'actif' a appuyé
                            case key of  // Instruction permettant de traiter les différents cas en fonction de la touche sur laquelle laa joueur 'actif' a appuyé 
                                UP :  // Le joueur 'actif' a appuyé sur la flèche du haut
                                    begin
                                        co[1] := 14;  // Coordonnées de la sortie correspondant à la touche flèche du haut
                                        co[2] := 19;
                                        if (caseEstLibre(joueurs, plat, co)) then  // Vérification de l'absence d'autre joueur sur la case sur laquelle le joueur 'actif' veut sortir. Si la condition est vraie, le joueur 'actif' va sortir de la salle
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                                joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;  // Diminition du nombre de déplacements restants
                                                bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                            end;
                                    end;
                                LEFT :  // Le joueur 'actif' a appuyé sur la flèche de gauche
                                    begin
                                        co[1] := 13;  // Coordonnées de la sortie correspondant à la touche flèche de gauche
                                        co[2] := 19;
                                        if (caseEstLibre(joueurs, plat, co)) then  // Vérification de l'absence d'autre joueur sur la case sur laquelle le joueur 'actif' veut sortir. Si la condition est vraie, le joueur 'actif' va sortir de la salle
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                                joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;  // Diminition du nombre de déplacements restants
                                                bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                            end;
                                    end;
                                RIGHT :  // Le joueur 'actif' a appuyé sur la flèche de droite
                                    begin
                                        co[1] := 17;  // Coordonnées de la sortie correspondant à la touche flèche de droite
                                        co[2] := 22;
                                        if (caseEstLibre(joueurs, plat, co)) then  // Vérification de l'absence d'autre joueur sur la case sur laquelle le joueur 'actif' veut sortir. Si la condition est vraie, le joueur 'actif' va sortir de la salle
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                                joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;  // Diminition du nombre de déplacements restants
                                                bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                            end;
                                    end;
                            end;
                            until (bouge);
                    end;
                9 :  // Le joueur 'actif' se trouve dans la salle 9
                    begin
                        affichageSortieSalle(9);  // Appel de la procedure affichageSortieSalle affichant les touches sur lesquelles appuyer pour sortir de cette salle
                        salle_act := 9;  // Variable stockant la valeur de salle dans laquelle le joueur 'actif' se trouve au début du tour
                        repeat  // Boucle se répétant tant que le joueur 'actif' n'est pas sortie de la salle dans laquelle il se trouve
                            key := readKey();  // Variable stockant la touche sur laquelle le joueur 'actif' a appuyé
                            case key of  // Instruction permettant de traiter les différents cas en fonction de la touche sur laquelle laa joueur 'actif' a appuyé 
                                UP :  // Le joueur 'actif' a appuyé sur la flèche du haut
                                    begin
                                        co[1] := 20;  // Coordonnées de la sortie correspondant à la touche flèche du haut
                                        co[2] := 22;
                                        if (caseEstLibre(joueurs, plat, co)) then  // Vérification de l'absence d'autre joueur sur la case sur laquelle le joueur 'actif' veut sortir. Si la condition est vraie, le joueur 'actif' va sortir de la salle
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                                joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;  // Diminition du nombre de déplacements restants
                                                bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                            end;
                                    end;
                                DOWN :  // Le joueur 'actif' a appuyé sur la flèche du bas. Dans ce cas, on n'a pas besoin de vérifier que la case est libre puisqu'il s'agit d'un passage secret que mène directement à une salle 
                                    begin
                                        co[1] := 6;  // Coordonnées de la sortie correspondant à la touche flèche du bas
                                        co[2] := 8;
                                        affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                        joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                        joueurs[j_actif].pos[2] := co[2];
                                        move := move - 1;  // Diminition du nombre de déplacements restants
                                        bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                    end;
                            end;
                            until (bouge);
                    end;
                10 :  // Le joueur 'actif' se trouve dans la salle 10
                    begin
                        affichageSortieSalle(10);  // Appel de la procedure affichageSortieSalle affichant les touches sur lesquelles appuyer pour sortir de cette salle
                        salle_act := 10;  // Variable stockant la valeur de salle dans laquelle le joueur 'actif' se trouve au début du tour
                        repeat  // Boucle se répétant tant que le joueur 'actif' n'est pas sortie de la salle dans laquelle il se trouve
                            key := readKey();  // Variable stockant la touche sur laquelle le joueur 'actif' a appuyé
                            case key of  // Instruction permettant de traiter les différents cas en fonction de la touche sur laquelle laa joueur 'actif' a appuyé 
                                DOWN :  // Le joueur 'actif' a appuyé sur la flèche du bas 
                                    begin
                                        co[1] := 14;  // Coordonnées de la sortie correspondant à la touche flèche du bas
                                        co[2] := 19;
                                        if (caseEstLibre(joueurs, plat, co)) then  // Vérification de l'absence d'autre joueur sur la case sur laquelle le joueur 'actif' veut sortir. Si la condition est vraie, le joueur 'actif' va sortir de la salle
                                            begin
                                                affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                                joueurs[j_actif].pos[1] := co[1];  // Actualisation de la position du pion du joueur 'actif'
                                                joueurs[j_actif].pos[2] := co[2];
                                                move := move - 1;  // Diminition du nombre de déplacements restants
                                                bouge := True;  // Le joueur 'actif' est sorti de la salle, donc bouge devient True et on sort de la boucle
                                            end;
                                    end;
                            end;
                            until (bouge);
                    end;
            end;
        end;


    {Déplace le pion en vérifiant les conditions de case d'arrivée, et réduit le nombre de déplacement restant jusqu'à que les déplacements restants soient à 0 ou que le joueur soit dans une salle}
    if (estDansLaSalle(plat, joueurs[j_actif].pos) = 0) then  // Vérification de la présence du joueur 'actif' dans aucune salle
        begin
            repeat  // Boucle se répétant tant que le joueur 'actif' n'est pas dans une salle ou qu'il lui reste des déplacements
	        	begin
                    affichageDeplacement(move);  // Appel de la procedure affichant le nombre de déplacements restants
		        	affiche(joueurs[j_actif].pion, joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Affiche la position du pion du joueur 'actif' sur le plateau de jeu
		        	key := readKey();  // Variable stockant la touche sur laquelle le joueur 'actif' a appuyé
		        	case key of  // Instruction permettant de traiter les différents cas en fonction de la touche sur laquelle laa joueur 'actif' a appuyé 
		        		UP :  // Déplacement en haut
                            begin
                                co[1] := joueurs[j_actif].pos[1];    // Coordonnées de la case située au dessus du joueur 'actif'
                                co[2] := joueurs[j_actif].pos[2] - 1;
                                // Vérification de la possibilité de déplacement sur la case co (que ce soit ni un mur, ni une case occupée par un autre joueur, ni une case de la salle dans laquelle le joueur 'actif' a commencé le tour si c'est le cas). Si la condition est vraie, le joueur 'actif' va se déplacer sur la case co
                                if ((joueurs[j_actif].pos[2] - 1 >= 2) AND (plat.grille[joueurs[j_actif].pos[1]][joueurs[j_actif].pos[2] - 1] <> 1) AND (caseEstLibre(joueurs, plat, co)) AND (salle_act <> estDansLaSalle(plat, co))) then
				        	        begin
				        	        	affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                        joueurs[j_actif].pos[2] := joueurs[j_actif].pos[2] - 1;  // Actualisation de la position du pion du joueur 'actif'
                                        move := move - 1;  // Diminition du nombre de déplacements restants
				        	        end;
                            end;
				        DOWN : // Déplacement en bas
                            begin
                                co[1] := joueurs[j_actif].pos[1];  // Coordonnées de la case située au dessous du joueur 'actif'
                                co[2] := joueurs[j_actif].pos[2] + 1;
                                // Vérification de la possibilité de déplacement sur la case co (que ce soit ni un mur, ni une case occupée par un autre joueur, ni une case de la salle dans laquelle le joueur 'actif' a commencé le tour si c'est le cas). Si la condition est vraie, le joueur 'actif' va se déplacer sur la case co
                                if ((joueurs[j_actif].pos[2] + 1 <= 26) AND (plat.grille[joueurs[j_actif].pos[1]][joueurs[j_actif].pos[2] + 1] <> 1) AND (caseEstLibre(joueurs, plat, co)) AND (salle_act <> estDansLaSalle(plat, co))) then
					                begin
					                	affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                        joueurs[j_actif].pos[2] := joueurs[j_actif].pos[2] + 1;  // Actualisation de la position du pion du joueur 'actif'
                                        move := move - 1;  // Diminition du nombre de déplacements restants
					                end;
                            end;
				        LEFT : // Déplacement à gauche
                            begin
                                co[1] := joueurs[j_actif].pos[1] - 1;  // Coordonnées de la case située à gauche du joueur 'actif'
                                co[2] := joueurs[j_actif].pos[2];
                                // Vérification de la possibilité de déplacement sur la case co (que ce soit ni un mur, ni une case occupée par un autre joueur, ni une case de la salle dans laquelle le joueur 'actif' a commencé le tour si c'est le cas). Si la condition est vraie, le joueur 'actif' va se déplacer sur la case co
                                if ((joueurs[j_actif].pos[1] - 1 >= 2) AND (plat.grille[joueurs[j_actif].pos[1] - 1][joueurs[j_actif].pos[2]] <> 1) AND (caseEstLibre(joueurs, plat, co)) AND (salle_act <> estDansLaSalle(plat, co))) then
				        	        begin
				        	        	affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                        joueurs[j_actif].pos[1] := joueurs[j_actif].pos[1] - 1;  // Actualisation de la position du pion du joueur 'actif'
                                        move := move - 1;  // Diminition du nombre de déplacements restants
                                    end;
				        	end;
				        RIGHT : // Déplacement à droite
                            begin
                                co[1] := joueurs[j_actif].pos[1] + 1;  // Coordonnées de la case située à droite du joueur 'actif'
                                co[2] := joueurs[j_actif].pos[2];
                                // Vérification de la possibilité de déplacement sur la case co (que ce soit ni un mur, ni une case occupée par un autre joueur, ni une case de la salle dans laquelle le joueur 'actif' a commencé le tour si c'est le cas). Si la condition est vraie, le joueur 'actif' va se déplacer sur la case co
                                if ((joueurs[j_actif].pos[1] + 1 <= 25) AND (plat.grille[joueurs[j_actif].pos[1] + 1][joueurs[j_actif].pos[2]] <> 1) AND (caseEstLibre(joueurs, plat, co)) AND (salle_act <> estDansLaSalle(plat, co))) then
					                begin
					        	        affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Efface l'ancienne position du pion du joueur 'actif' sur le plateau de jeu
                                        joueurs[j_actif].pos[1] := joueurs[j_actif].pos[1] + 1;  // Actualisation de la position du pion du joueur 'actif'
                                        move := move - 1;  // Diminition du nombre de déplacements restants
                                    end;
					        end;
                    end;
		        end;
		        until ((move = 0) OR (estDansLaSalle(plat, joueurs[j_actif].pos) <> 0));
        end;
        
    
    placementSalle(joueurs, plat, j_actif);  // Appel de la procédure pour placer le joueur dans la salle dans laquelle il se trouve, si c'est le cas
    affiche(joueurs[j_actif].pion, joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);  // Affiche la position du pion du joueur 'actif' sur le plateau de jeu
    affichageDeplacement(move);  // Appel de la procedure affichant le nombre de déplacements restants
    Delay(1000);  // Le programme attend environ 1000 ms avant de continuer 
    ClrScr;  // Le terminal est nettoyé
end;



procedure placementSalle(var joueurs : ListeJoueurs; plat : Plateau; j_actif : Integer);

var co : Coords;
    i : Integer;

begin
    i := 1;


	if (estDansLaSalle(plat, joueurs[j_actif].pos) <> 0) then
        begin
            affiche(' ', joueurs[j_actif].pos[1], joueurs[j_actif].pos[2]);
			case estDansLaSalle(plat, joueurs[j_actif].pos) of
                1 : 
                    begin
                        repeat
                            case i of
                                1 : begin
                                        co[1] := 3;
                                        co[2] := 5;
                                    end;
                                2 : begin
                                        co[1] := 4;
                                        co[2] := 5;
                                    end;
                                3 : begin
                                        co[1] := 5;
                                        co[2] := 5;
                                    end;
                                4 : begin
                                        co[1] := 3;
                                        co[2] := 6;
                                    end;
                                5 : begin
                                        co[1] := 4;
                                        co[2] := 6;
                                    end;
                                6 : begin
                                        co[1] := 5;
                                        co[2] := 6;
                                    end;
                            end;

                            if caseEstLibre(joueurs, plat, co) then
                                begin
                                    joueurs[j_actif].pos[1] := co[1];
						            joueurs[j_actif].pos[2] := co[2];
                                end;

                            i := i + 1;

                            until((joueurs[j_actif].pos[1] = co[1]) AND (joueurs[j_actif].pos[2] = co[2]));
                    end;                                
                2 : 
                    begin
                        repeat
                            case i of
                                1 : begin
                                        co[1] := 12;
                                        co[2] := 6;
                                    end;
                                2 : begin
                                        co[1] := 13;
                                        co[2] := 6;
                                    end;
                                3 : begin
                                        co[1] := 14;
                                        co[2] := 6;
                                    end;
                                4 : begin
                                        co[1] := 15;
                                        co[2] := 6;
                                    end;
                                5 : begin
                                        co[1] := 13;
                                        co[2] := 7;
                                    end;
                                6 : begin
                                        co[1] := 14;
                                        co[2] := 7;
                                    end;
                            end;

                            if caseEstLibre(joueurs, plat, co) then
                                begin
                                    joueurs[j_actif].pos[1] := co[1];
						            joueurs[j_actif].pos[2] := co[2];
                                end;

                            i := i + 1;

                            until((joueurs[j_actif].pos[1] = co[1]) AND (joueurs[j_actif].pos[2] = co[2]));
                    end;
                3 : 
                    begin
                        repeat
                            case i of
                                1 : begin
                                        co[1] := 22;
                                        co[2] := 4;
                                    end;
                                2 : begin
                                        co[1] := 23;
                                        co[2] := 4;
                                    end;
                                3 : begin
                                        co[1] := 24;
                                        co[2] := 4;
                                    end;
                                4 : begin
                                        co[1] := 22;
                                        co[2] := 5;
                                    end;
                                5 : begin
                                        co[1] := 23;
                                        co[2] := 5;
                                    end;
                                6 : begin
                                        co[1] := 24;
                                        co[2] := 5;
                                    end;
                            end;

                            if caseEstLibre(joueurs, plat, co) then
                                begin
                                    joueurs[j_actif].pos[1] := co[1];
						            joueurs[j_actif].pos[2] := co[2];
                                end;

                            i := i + 1;

                            until((joueurs[j_actif].pos[1] = co[1]) AND (joueurs[j_actif].pos[2] = co[2]));
                    end;
                4 : 
                    begin
                        repeat
                            case i of
                                1 : begin
                                        co[1] := 4;
                                        co[2] := 14;
                                    end;
                                2 : begin
                                        co[1] := 5;
                                        co[2] := 14;
                                    end;
                                3 : begin
                                        co[1] := 6;
                                        co[2] := 14;
                                    end;
                                4 : begin
                                        co[1] := 7;
                                        co[2] := 14;
                                    end;
                                5 : begin
                                        co[1] := 5;
                                        co[2] := 15;
                                    end;
                                6 : begin
                                        co[1] := 6;
                                        co[2] := 15;
                                    end;
                            end;

                            if caseEstLibre(joueurs, plat, co) then
                                begin
                                    joueurs[j_actif].pos[1] := co[1];
						            joueurs[j_actif].pos[2] := co[2];
                                end;

                            i := i + 1;

                            until((joueurs[j_actif].pos[1] = co[1]) AND (joueurs[j_actif].pos[2] = co[2]));
                    end;
                5 : 
                    begin
                        repeat
                            case i of
                                1 : begin
                                        co[1] := 22;
                                        co[2] := 12;
                                    end;
                                2 : begin
                                        co[1] := 23;
                                        co[2] := 12;
                                    end;
                                3 : begin
                                        co[1] := 24;
                                        co[2] := 12;
                                    end;
                                4 : begin
                                        co[1] := 22;
                                        co[2] := 13;
                                    end;
                                5 : begin
                                        co[1] := 23;
                                        co[2] := 13;
                                    end;
                                6 : begin
                                        co[1] := 24;
                                        co[2] := 13;
                                    end;
                            end;

                            if caseEstLibre(joueurs, plat, co) then
                                begin
                                    joueurs[j_actif].pos[1] := co[1];
						            joueurs[j_actif].pos[2] := co[2];
                                end;

                            i := i + 1;

                            until((joueurs[j_actif].pos[1] = co[1]) AND (joueurs[j_actif].pos[2] = co[2]));
                    end;
                6 : 
                    begin
                        repeat
                            case i of
                                1 : begin
                                        co[1] := 22;
                                        co[2] := 17;
                                    end;
                                2 : begin
                                        co[1] := 23;
                                        co[2] := 17;
                                    end;
                                3 : begin
                                        co[1] := 24;
                                        co[2] := 17;
                                    end;
                                4 : begin
                                        co[1] := 22;
                                        co[2] := 18;
                                    end;
                                5 : begin
                                        co[1] := 23;
                                        co[2] := 18;
                                    end;
                                6 : begin
                                        co[1] := 24;
                                        co[2] := 18;
                                    end;
                            end;

                            if caseEstLibre(joueurs, plat, co) then
                                begin
                                    joueurs[j_actif].pos[1] := co[1];
						            joueurs[j_actif].pos[2] := co[2];
                                end;

                            i := i + 1;

                            until((joueurs[j_actif].pos[1] = co[1]) AND (joueurs[j_actif].pos[2] = co[2]));
                    end;
                7 : 
                    begin
                        repeat
                            case i of
                                1 : begin
                                        co[1] := 3;
                                        co[2] := 24;
                                    end;
                                2 : begin
                                        co[1] := 4;
                                        co[2] := 24;
                                    end;
                                3 : begin
                                        co[1] := 5;
                                        co[2] := 24;
                                    end;
                                4 : begin
                                        co[1] := 6;
                                        co[2] := 24;
                                    end;
                                5 : begin
                                        co[1] := 4;
                                        co[2] := 25;
                                    end;
                                6 : begin
                                        co[1] := 5;
                                        co[2] := 25;
                                    end;
                            end;

                            if caseEstLibre(joueurs, plat, co) then
                                begin
                                    joueurs[j_actif].pos[1] := co[1];
						            joueurs[j_actif].pos[2] := co[2];
                                end;

                            i := i + 1;

                            until((joueurs[j_actif].pos[1] = co[1]) AND (joueurs[j_actif].pos[2] = co[2]));
                    end;
                8 : 
                    begin
                        repeat
                            case i of
                                1 : begin
                                        co[1] := 13;
                                        co[2] := 22;
                                    end;
                                2 : begin
                                        co[1] := 14;
                                        co[2] := 22;
                                    end;
                                3 : begin
                                        co[1] := 13;
                                        co[2] := 23;
                                    end;
                                4 : begin
                                        co[1] := 14;
                                        co[2] := 23;
                                    end;
                                5 : begin
                                        co[1] := 13;
                                        co[2] := 24;
                                    end;
                                6 : begin
                                        co[1] := 14;
                                        co[2] := 24;
                                    end;
                            end;

                            if caseEstLibre(joueurs, plat, co) then
                                begin
                                    joueurs[j_actif].pos[1] := co[1];
						            joueurs[j_actif].pos[2] := co[2];
                                end;

                            i := i + 1;

                            until((joueurs[j_actif].pos[1] = co[1]) AND (joueurs[j_actif].pos[2] = co[2]));
                    end;
                9 : 
                    begin
                        repeat
                            case i of
                                1 : begin
                                        co[1] := 21;
                                        co[2] := 25;
                                    end;
                                2 : begin
                                        co[1] := 22;
                                        co[2] := 25;
                                    end;
                                3 : begin
                                        co[1] := 23;
                                        co[2] := 25;
                                    end;
                                4 : begin
                                        co[1] := 24;
                                        co[2] := 25;
                                    end;
                                5 : begin
                                        co[1] := 22;
                                        co[2] := 26;
                                    end;
                                6 : begin
                                        co[1] := 23;
                                        co[2] := 26;
                                    end;
                            end;

                            if caseEstLibre(joueurs, plat, co) then
                                begin
                                    joueurs[j_actif].pos[1] := co[1];
						            joueurs[j_actif].pos[2] := co[2];
                                end;

                            i := i + 1;

                            until((joueurs[j_actif].pos[1] = co[1]) AND (joueurs[j_actif].pos[2] = co[2]));
                    end;
                10 : 
                    begin
                        repeat
                            case i of
                                1 : begin
                                        co[1] := 13;
                                        co[2] := 15;
                                    end;
                                2 : begin
                                        co[1] := 14;
                                        co[2] := 15;
                                    end;
                                3 : begin
                                        co[1] := 15;
                                        co[2] := 15;
                                    end;
                                4 : begin
                                        co[1] := 13;
                                        co[2] := 16;
                                    end;
                                5 : begin
                                        co[1] := 14;
                                        co[2] := 16;
                                    end;
                                6 : begin
                                        co[1] := 15;
                                        co[2] := 16;
                                    end;
                            end;

                            if caseEstLibre(joueurs, plat, co) then
                                begin
                                    joueurs[j_actif].pos[1] := co[1];
						            joueurs[j_actif].pos[2] := co[2];
                                end;

                            i := i + 1;

                            until((joueurs[j_actif].pos[1] = co[1]) AND (joueurs[j_actif].pos[2] = co[2]));
                    end;
			end;
		end;
end;



procedure faireHypothese(var joueurs : ListeJoueurs; var hypo : array of ListeCartes; plat : Plateau; j_actif : Integer; environnement : Enviro);

var g1, g2, reveal, carte : ListeCartes;
    perso, arme, temp : set of ListeCartes;
    i, j, k, l, nb : Integer;
    montrer : Boolean;
    commun : Array of ListeCartes;

begin 
    {Déclaration et remplissage des ensembles personnage et arme propre à l'envrionnement}
    perso := [];
    arme := [];
    if environnement = Manoir then
        begin
            for carte := Colonel_Moutarde to Madame_Leblanc do
                Include(perso, carte);
            for carte := Poignard to Clef_Anglaise do
                Include(arme, carte);
        end
    else
        begin
            for carte := Monsieur_Bredel to Infirmiere do
                Include(perso, carte);
            for carte := Seringue to Pouf_Rouge do
                Include(arme, carte);
        end;


    ClrScr;
    affichageCartes(joueurs, j_actif);


    {Enregistre les éléments de l'hypothèse}
    writeln('Vous allez formuler une hypothese !');

    repeat
        write('Selon vous, qui pourrait-etre l''assassin ? Voici les choix possibles : ');
        for carte in perso do write(carte, ' ');
        writeln();
        readln(g1);
        if not(g1 in perso) then
            writeln('La carte ne correspond pas a un personnage.')
        until (g1 in perso);
    hypo[1] := g1;

    repeat
        write('Selon vous, quelle pourrait-etre l''arme du crime ? Voici les choix possibles : ');
        for carte in arme do write(carte, ' ');
        writeln();
        readln(g2);
        if not(g2 in arme) then
            writeln('La carte ne correspond pas a une arme')
        until (g2 in arme);
    hypo[2] := g2;

    hypo[3] := plat.salles[estDansLaSalle(plat, joueurs[j_actif].pos)].nom;


    {Déplace le joueur accusé si il fait partie des joueurs}
    i := 1;
    repeat
        if (hypo[1] = joueurs[i].perso) then
            begin
                affiche(' ', joueurs[i].pos[1], joueurs[i].pos[2]);
                case estDansLaSalle(plat, joueurs[j_actif].pos) of
                    1 : begin
                            joueurs[i].pos[1] := 6;
                            joueurs[i].pos[2] := 8;
                        end;
                    2 : begin
                            joueurs[i].pos[1] := 11;
                            joueurs[i].pos[2] := 9;
                        end;
                    3 : begin
                            joueurs[i].pos[1] := 21;
                            joueurs[i].pos[2] := 6;
                        end;
                    4 : begin
                            joueurs[i].pos[1] := 9;
                            joueurs[i].pos[2] := 14;
                        end;
                    5 : begin
                            joueurs[i].pos[1] := 24;
                            joueurs[i].pos[2] := 14;
                        end;
                    6 : begin
                            joueurs[i].pos[1] := 22;
                            joueurs[i].pos[2] := 16;
                        end;
                    7 : begin
                            joueurs[i].pos[1] := 7;
                            joueurs[i].pos[2] := 21;
                        end;
                    8 : begin
                            joueurs[i].pos[1] := 13;
                            joueurs[i].pos[2] := 20;
                        end;
                    9 : begin
                            joueurs[i].pos[1] := 20;
                            joueurs[i].pos[2] := 23;
                        end;
                end;
            placementSalle(joueurs, plat, i);
            affiche(joueurs[i].pion, joueurs[i].pos[1], joueurs[i].pos[2]);
        end;
        i := i + 1;
        until ((i = length(joueurs) + 1) OR (hypo[1] = joueurs[i-1].perso));
    




    {Affiche l'hypothèse en entière}
    writeln('Votre hypothese est donc la suivante : ', hypo[1], ' ', hypo[2], ' ', hypo[3]);
    Delay(5000);


    {Demande aux joueurs suivants si il possède une des cartes de l'hypothèse formulée}
    ClrScr;
    montrer := False;
    j := j_actif;
    i := 1;


    {Répète la demande au joueur en stockant les cartes en commun entre le joueur j et l'hypothèse formulée jusqu'à ce qu'une carte coincide ou que tout les joueurs aient été interrogés}
    repeat 
        if (j + 1 > length(joueurs)) then
            j := (j + 1) mod length(joueurs)
        else
            j := j + 1;


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

                affichageMontrerCartes(commun, joueurs, j, j_actif, reveal);
                montrer := True;
                SetLength(commun, 0);
            end
        else
            begin
                colorPerso(joueurs, j);
                write(joueurs[j].perso);
                TextColor(15);
                writeln(' n''as aucune des cartes de votre hypothese.');
                Delay(1000);
            end;

        i := i + 1;

        until (montrer OR (i = length(joueurs)));


    {Affiche au j_actif qu'aucun des joueurs ne possède les cartes de l'hypothèse si c'est le cas}
    if not(montrer) then
        writeln('Aucun des enqueteurs ne possede une carte de votre hypothese !');    
end;



procedure faireAccusation(var etui : Array of ListeCartes; var joueurs : ListeJoueurs; var accusation : Boolean; j_actif : Integer; environnement : Enviro; plat : Plateau);

var guess : Array [1..3] of ListeCartes;
    g1, g2, g3, carte : ListeCartes;
    perso, arme, lieu : set of ListeCartes;
    i : Integer;

begin 
    {Déclaration et remplissage des ensembles personnage et arme propre à l'envrionnement}
    perso := [];
    arme := [];
    lieu := [];
    if environnement = Manoir then
        begin
            for carte := Colonel_Moutarde to Madame_Leblanc do
                Include(perso, carte);
            for carte := Poignard to Clef_Anglaise do
                Include(arme, carte);
            for carte := Cuisine to Studio do
                Include(lieu, carte);
        end
    else
        begin  
            for carte := Monsieur_Bredel to Infirmiere do
                Include(perso, carte);
            for carte := Seringue to Pouf_Rouge do
                Include(arme, carte);
            for carte := Cafete to BU do
                Include(lieu, carte);
        end;


    ClrScr;
    affichageCartes(joueurs, j_actif);


    {Enregistre les éléments de l'accusation}
    writeln('Vous allez formuler une accusation !');

    repeat
        write('Selon vous, qui est l''assassin ? ');
        readln(g1);
        if not(g1 in perso) then
            writeln('La carte ne correspond pas a un personnage.')
        until (g1 in perso);
    guess[1] := g1;

    repeat
        write('Selon vous, quelle est l''arme du crime ? ');
        readln(g2);
        if not(g2 in arme) then
            writeln('La carte ne correspond pas a une arme')
        until (g2 in arme);
    guess[2] := g2;

    repeat
        write('Selon vous, dans quelle salle l''assassinat a-t-il eu lieu ? ');
        readln(g3);
        if not(g3 in lieu) then
            writeln('La carte ne correspond pas a un lieu')
        until (g3 in lieu);
    guess[3] := g3;

       
       
        {Déplace le joueur accusé si il fait partie des joueurs}
    i := 1;
    repeat
        if (guess[1] = joueurs[i].perso) then
            begin
                affiche(' ', joueurs[i].pos[1], joueurs[i].pos[2]);
                joueurs[i].pos[1] := 14;
                joueurs[i].pos[2] := 18;     
                placementSalle(joueurs, plat, i);
                affiche(joueurs[i].pion, joueurs[i].pos[1], joueurs[i].pos[2]);
            end;
        i := i + 1;
        until ((i = length(joueurs) + 1) OR (guess[1] = joueurs[i-1].perso));
   
   
   
    {Vérifie que les ensembles de l'accusation et de l'étui coincident, sinon le joueur du tour meurt}
    if ((etui[1] = guess[1]) AND (etui[2] = guess[2]) AND (etui[3] = guess[3])) then
        accusation := True
    else
        begin
            joueurs[j_actif].enVie := False;
            ClrScr;
            write('Malheuresement, l''accusation de ');
            colorPerso(joueurs, j_actif);
            write(joueurs[j_actif].perso);
            TextColor(15);
            writeln(' n''etait pas la bonne. Il ne fait donc plus partie de l''enquete.');
        end;
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
    
            writeln('La partie est terminee ! Un enqueteur a trouve le meurtrier, l''arme du crime et le lieu de l''assassinnat.');
            write('Et cet en enqueteur est ');
            colorPerso(joueurs, j_actif);
            write(joueurs[j_actif].perso);
            TextColor(15); 
            writeln(' !');
            write('Voici les elements du meurtre : ', etui[1], ' ', etui[2], ' ', etui[3], '.');
        end
    else
        begin
            writeln('Aucun des enqueteurs n''est parvenu a resoudre ce meurtre. La partie est finie.');
            writeln('Voici les elements du meurtre : ', etui[1], ' ', etui[2], ' ', etui[3], '.');
        end;
end;



procedure quitterSauvegarder(var joueurs : ListeJoueurs; var etui : Array of ListeCartes; j_actif : Integer; environnement : Enviro);

var nomFichier : String;
    nb_cartes, i, c : Integer;
    carte : ListeCartes;
    sauvegarde : Text;
    continue : Boolean;

begin
    writeln('Voulez-vous sauvegarder la partie en cours ?');
    writeln('   1 : Oui');
    writeln('   2 : Non');
    repeat
        write('Votre choix est : ');
        readln(c);
        if not((c >= 1) AND (c <= 2)) then
            writeln('Ce choix n''est pas valide.')
    until ((c >= 1) AND (c <= 2));

    if (c = 1) then
        begin
            {Création du fichier sauvegarde}
            write('Comment souhaitez-vous nommer votre sauvegarde (avec .txt en extension) : ');
            continue := False;
            repeat
                readln(nomFichier);
                if FileExists(nomFichier) then
                    begin
                        repeat
                            writeln('Ce fichier existe deja. Voulez l''ecraser ou rentrer un autre nom ? ');
                            writeln('   1 : Ecraser');
                            writeln('   2 : Changer de nom');
                            write('Votre choix est : ');
                            if not((c >= 1) AND (c <= 2)) then
                                writeln('Ce choix n''est pas valide.');
                            until ((c >= 1) AND (c <= 2));

                        if (c = 1) then
                            continue := True;
                    end
                else
                    continue := True;
                until (continue);

            assign(sauvegarde, nomFichier);
            rewrite(sauvegarde);

            {Environnement de la partie}
            writeln(sauvegarde, environnement);


            {Nombre de joueurs dans la partie}
            writeln(sauvegarde, length(joueurs)); 


            {Initialisation des joueurs, de leurs propriétés et de leurs cartes}
            for i := 1 to length(joueurs) do
                begin
                    writeln(sauvegarde, joueurs[i].enVie);
           
                    nb_cartes:= 0;
                    for carte in joueurs[i].cartes do
                    nb_cartes:=nb_cartes + 1;

                    writeln(sauvegarde, nb_cartes);
                    for carte in joueurs[i].cartes do
                        writeln(sauvegarde, carte);
           
            
                    writeln(sauvegarde, joueurs[i].pos[1]);
                    writeln(sauvegarde, joueurs[i].pos[2]);

                    writeln(sauvegarde,  joueurs[i].perso);
                    writeln(sauvegarde,  joueurs[i].pion);
                end;
    
            for i := 1 to 3 do
                writeln(sauvegarde, etui[i]);

            writeln(sauvegarde, j_actif);

            {fermeture du fichier}
            close(sauvegarde);
        end;
end;



function estDansLaSalle(plat : Plateau; coordonnees : Coords) : Integer;

var co : Coords;
    i : Integer;

begin
    {Renvoie la salle dans laquelle le joueur se trouve}
    i := 1;
    estDansLaSalle := 0;
    repeat
        for co in plat.salles[i].cases do
            begin
                if ((co[1] = coordonnees[1]) AND (co[2] = coordonnees[2])) then
                    estDansLaSalle := i;
            end;
        i := i + 1;
        until ((i = 11) OR (estDansLaSalle = i - 1));        
end;



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



function sortieSallePossible(joueurs : ListeJoueurs; plat : Plateau; j_actif : Integer) : Boolean;

var co1, co2, co3, co4 : Coords;

begin
    sortieSallePossible := True;
    case estDansLaSalle(plat, joueurs[j_actif].pos) of
        2 : begin
                co1[1] := 11;
                co1[2] := 10;

                co2[1] := 16;
                co2[2] := 10;

                co3[1] := 9;
                co3[2] := 7;

                co4[1] := 18;
                co4[2] := 7;

                if not((caseEstLibre(joueurs, plat, co1) AND caseEstLibre(joueurs, plat, co2) AND caseEstLibre(joueurs, plat, co3) AND caseEstLibre(joueurs, plat, co4))) then
                    sortieSallePossible := False;
            end;
        4 : begin
                co1[1] := 8;
                co1[2] := 18;

                co2[1] := 10;
                co2[2] := 14;

                if not((caseEstLibre(joueurs, plat, co1) AND caseEstLibre(joueurs, plat, co2))) then
                    sortieSallePossible := False;
            end;
        5 : begin
                co1[1] := 24;
                co1[2] := 15;

                co2[1] := 19;
                co2[2] := 11;

                if not((caseEstLibre(joueurs, plat, co1) AND caseEstLibre(joueurs, plat, co2))) then
                    sortieSallePossible := False;
            end;
        6 : begin
                co1[1] := 22;
                co1[2] := 15;

                co2[1] := 18;
                co2[2] := 18;

                if not((caseEstLibre(joueurs, plat, co1) AND caseEstLibre(joueurs, plat, co2))) then
                    sortieSallePossible := False;
            end;
        8 : begin
                co1[1] := 14;
                co1[2] := 19;

                co2[1] := 13;
                co2[2] := 19;

                co3[1] := 17;
                co3[2] := 22;

                if not((caseEstLibre(joueurs, plat, co1) AND caseEstLibre(joueurs, plat, co2) AND caseEstLibre(joueurs, plat, co3))) then
                    sortieSallePossible := False;
            end;
        10 : begin
                co1[1] := 14;
                co1[2] := 19;

                if not(caseEstLibre(joueurs, plat, co1)) then
                    sortieSallePossible := False;
            end;
    end;

end;


end.