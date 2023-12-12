program Cluedo;


uses unite, Crt, configurationPartie, partie, affichage;


procedure menu(var c : Integer);
{Procedure permettant a l'utilisateur de choisir ce qu'il veut faire}

begin
    writeln('Que voulez-vous faire :');  // Demande a l'utilisateur si il veut lancer une partie, afficher les regles ou quitter le jeu
    writeln('   1 : Lancer une partie');
    writeln('   2 : Afficher les regles du jeu');
    writeln('   3 : Quitter');
    repeat  // Boucle se repetant tant que le choix n'est pas correct
        write('Votre choix est : ');
        readln(c);
        if not((c >= 1) AND (c <= 3)) then
            writeln('Ce choix n''est pas disponible.')
    until ((c >= 1) AND (c <= 3));
end;


procedure quitter();
{Procedure permettant de quitter le jeu}

begin
    ClrScr;
    writeln('Merci d''avoir joue !');
    Delay(3000);
    ClrScr;
end;


procedure afficherRegles();
{Procedure permettant d'afficher les regles}

var ligne : String;
    regles : Text;
    key : Char;

begin
    assign(regles, 'regles.txt');  // Liaison entre le fichier regles.txt et la variable regles
    reset(regles);  // Lecture du fichier 
    while not(eof(regles)) do  // Boucle parcourant les lignes du fichier regles
        begin
            readln(regles, ligne);
            writeln(ligne);
        end;
    repeat  // Boucle se repetant jusqu'a ce que 'q' soit pressee
        key := readKey();
        until (key = QUIT);
    ClrScr;
    close(regles);  // fermeture du fichier regles
end;


var c, j_actif : Integer;
    environnement : Enviro;
    joueurs : ListeJoueurs;
    plat : Plateau;
    etui : Array [1..3] of ListeCartes;

begin
    ClrScr;
    repeat  // Boucle se repetant tant que le programme tourne
        menu(c);
        case c of  // Instruction permettant de traiter les differents cas en fonction du choix de l'utilisateur
            1 : begin  // Cas de lancement d'une partie
                    configPartie(joueurs, plat, etui, environnement, j_actif);
                    jeu(etui, plat, joueurs, environnement, j_actif);
                    {Liberation espace memoire}
                    SetLength(joueurs, 0);
                end;
            2 : afficherRegles();  // Cas de l'affichage des regles
            3 : quitter();  // Cas de la fermeture du jeu
        end;
        until (c = 3);
end.