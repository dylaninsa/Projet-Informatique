program Cluedo;


uses unite, Crt, configurationPartie, partie, affichage;


procedure menu(var c : Integer);

begin
    writeln('Que voulez-vous faire :');
    writeln('   1 : Lancer une partie');
    writeln('   2 : Afficher les regles du jeu');
    writeln('   3 : Quitter');
    repeat
        write('Votre choix est : ');
        readln(c);
        if not((c >= 1) AND (c <= 3)) then
            writeln('Ce choix n''est pas disponible.')
    until ((c >= 1) AND (c <= 3));
end;


procedure quitter();

begin
    ClrScr;
    Halt;
end;


procedure afficherRegles();

var ligne : String;
    regles : Text;
    key : Char;

begin
    assign(regles, 'regles.txt');
    reset(regles);
    while not(eof(regles)) do
        begin
            readln(regles, ligne);
            writeln(ligne);
        end;
    repeat
        key := readKey();
        until (key = QUIT);
    ClrScr;
    close(regles);
end;


var c, j_actif : Integer;
    environnement : Enviro;
    joueurs : ListeJoueurs;
    plat : Plateau;
    etui : Array [1..3] of ListeCartes;

begin
    ClrScr;
    repeat
        menu(c);
        case c of
            1 : begin
                    configPartie(joueurs, plat, etui, environnement, j_actif);
                    jeu(etui, plat, joueurs, environnement, j_actif);
                    {Libération espace mémoire}
                    SetLength(joueurs, 0);
                end;
            2 : afficherRegles();
            3 : quitter();
        end;
        until (c = 3);
end.