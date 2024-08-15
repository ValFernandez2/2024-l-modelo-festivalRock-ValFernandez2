%BASE DE CONOCIMIENTO
anioActual(2015).

%festival(nombre, lugar, bandas, precioBase).
%lugar(nombre, capacidad).
festival(lulapaluza, lugar(hipodromo,40000), [miranda, paulMasCarne, muse], 500).
festival(mostrosDelRock, lugar(granRex, 10000), [kiss, judasPriest, blackSabbath], 1000).
festival(personalFest, lugar(geba, 5000), [tanBionica, miranda, muse, pharrellWilliams], 300).
festival(cosquinRock, lugar(aerodromo, 2500), [erucaSativa, laRenga], 400).

%banda(nombre, año, nacionalidad, popularidad).
banda(paulMasCarne,1960, uk, 70).
banda(muse,1994, uk, 45).
banda(kiss,1973, us, 63).
banda(erucaSativa,2007, ar, 60).
banda(judasPriest,1969, uk, 91).
banda(tanBionica,2012, ar, 71).
banda(miranda,2001, ar, 38).
banda(laRenga,1988, ar, 70).
banda(blackSabbath,1968, uk, 96).
banda(pharrellWilliams,2014, us, 85).

%entradasVendidas(nombreDelFestival, tipoDeEntrada, cantidadVendida).
% tipos de entrada: campo, plateaNumerada(numero de fila), plateaGeneral(zona).
entradasVendidas(lulapaluza,campo, 600).
entradasVendidas(lulapaluza,plateaGeneral(zona1), 200).
entradasVendidas(lulapaluza,plateaGeneral(zona2), 300).
entradasVendidas(mostrosDelRock,campo,20000).
entradasVendidas(mostrosDelRock,plateaNumerada(1),40).
entradasVendidas(mostrosDelRock,plateaNumerada(2),0).
% … y asi para todas las filas
entradasVendidas(mostrosDelRock,plateaNumerada(10),25).
entradasVendidas(mostrosDelRock,plateaGeneral(zona1),300).
entradasVendidas(mostrosDelRock,plateaGeneral(zona2),500).

plusZona(hipodromo, zona1, 55).
plusZona(hipodromo, zona2, 20).
plusZona(granRex, zona1, 45).
plusZona(granRex, zona2, 30).
plusZona(aerodromo, zona1, 25).


%PUNTO 1
%BANDA DE MODA
estaDeModa(Banda):-
    banda(Banda,FechaSurgio,_,Popularidad),
    bandaNueva(FechaSurgio),
    Popularidad > 70.

bandaNueva(Fecha):-
    anioActual(Anio),
    (Anio - Fecha) =< 5.


%PUNTO 2
%FESTIVAL CARETA
esCareta(Festival):-
    festival(Festival,_,Bandas,_),
    member(miranda,Bandas).
esCareta(Festival):-
    festival(Festival,_,Bandas,_),
    banda(Banda,_,_,_),
    findall(Banda,(estaDeModa(Banda),member(Banda,Bandas)),BandasDeModa),
    length(BandasDeModa,Cantidad),
    Cantidad >= 2.
esCareta(Festival):-
    festival(Festival,_,_,_),
    forall(entradasVendidas(Festival,Entrada,_),not(entradaRazonable(Festival,Entrada))).


%PUNTO 3
%ENTRADAS RAZONABLES
entradaRazonable(Festival,plateaGeneral(Zona)):-
    festival(Festival,lugar(Lugar,_),_,PrecioBase),
    plusZona(Lugar,Zona,Plus),
    (PrecioBase * 0.1) > Plus.
entradaRazonable(Festival,campo):-
    festival(Festival,_,_,PrecioBase),
    popularidad(Festival,Popularidad),
    PrecioBase > Popularidad.
entradaRazonable(Festival,plateaNumerada(_)):-
    festival(Festival,_,Bandas,_),
    banda(Banda,_,_,_),
    forall(member(Banda,Bandas),not(estaDeModa(Banda))),
    precio(Festival,plateaNumerada(1),Precio),
    Precio < 750.
entradaRazonable(Festival,plateaNumerada(_)):-
    festival(Festival,_,_,Popularidad),
    precio(Festival,plateaNumerada(1),Precio),
    popularidad(Festival,Popularidad),
    Precio < Popularidad.

precio(Festival,campo,Precio):- festival(Festival,_,_,Precio).
precio(Festival,plateaNumerada(Numero),Precio):- 
    festival(Festival,_,_,PrecioBase), 
    Precio is (PrecioBase+(200/Numero)).
precio(Festival,plateaGeneral(Zona),Precio):-
    festival(Festival,lugar(Lugar,_),_,PrecioBase),
    plusZona(Lugar,Zona,Plus),
    Precio is PrecioBase + Plus.

popularidad(Festival,Cantidad):-
    festival(Festival,_,Bandas,_),
    findall(Popularidad,(banda(Banda,_,_,Popularidad),member(Banda,Bandas)),Popularidades),
    sum_list(Popularidades, Cantidad).  
    

%PUNTO 4
%FESTIVAL NAC AND POP
nacAndPop(Festival):-
    festival(Festival,_,Bandas,_),
    banda(Banda,_,_,_),
    forall(member(Banda,Bandas),banda(Banda,_,ar,_)),
    member(Entrada,(entradaRazonable(Festival,Entrada),festival(Festival,_,_,_))).

%PUNTO 5
%RECAUDACION TOTAL
recaudacion(Festival,Recaudado):-
    festival(Festival,_,_,_),
    precio(Festival,_,_),
    findall(Recaudacion,(entradasVendidas(Festival,Entrada,_),calcularRecaudacion(Festival,Entrada,Recaudacion)),ListaRecaudado),
    sum_list(ListaRecaudado, Recaudado).
      
calcularRecaudacion(Festival,Entrada,Recaudado):-
    precio(Festival,Entrada,Precio),
    entradasVendidas(Festival,Entrada,Cantidad),
    Recaudado is Precio * Cantidad.
    
%PUNTO 6
%FESTIVAL BIEN PLANEADO
bienPlaneado(Festival):-
    festival(Festival,_,Bandas,_),
    crecenEnPopularidad(Bandas),
    ultimaLegendaria(Bandas).

%Auxiliares para última legendaria
ultimaLegendaria(Bandas):-
    reverse(Bandas, [Primera|_]),
    esLegendaria(Primera).

esLegendaria(Banda):-
    banda(Banda,Fecha,Pais,Popularidad),
    Fecha < 1980,
    Pais \= ar,
    masQueLasDeModa(Popularidad).

masQueLasDeModa(Popularidad):-
    findall(Popularidades,(banda(Banda,_,_,Popularidades),estaDeModa(Banda)),Lista),
    forall(member(PopuModa,Lista),Popularidad > PopuModa).

%Auxiliares para crecen en popularidad
crecenEnPopularidad([X,Y]):-
    banda(X,_,_,Popularidad1),
    banda(Y,_,_,Popularidad2),
    Popularidad1 < Popularidad2.
crecenEnPopularidad([X,Y|Resto]):-
    banda(X,_,_,Popularidad1),
    banda(Y,_,_,Popularidad2),
    Popularidad1 < Popularidad2,
    crecenEnPopularidad([Y|Resto]).

    
    