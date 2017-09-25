// name generator

class GenName
{
  // generate a name
  public static function generate(): String
    {
      var name = names[Std.int(Math.random() * (names.length - 1))];
      var surname = surnames[Std.int(Math.random() * (surnames.length - 1))];

      return name + " " + surname;
    }


  static var names: Array<String> = [
    "Austin",
    "Barbara", // 1
    "Calvin",
    "Carl",
    "Catherine", // 1
    "Clarence",
    "Donald",
    "Dwight",
    "Ed",
    "Evelyn", // 1
    "Kevin",
    "Lester",
    "Mark",
    "Oscar",
    "Patricia", // 1
    "Samuel",
    "Sigourney", // 1
    "Spencer",
    "Tom",
    "Virgil",

    "Adam",
    "Alan",
    "Andrea", // 1
    "Arthur",
    "Brett",
    "Damien",
    "David",
    "Frank",
    "Helen", // 1
    "James",
    "Jane", // 1
    "John",
    "Maria", // 1
    "Michael",
    "Neil",
    "Patrick",
    "Paul",
    "Randolph",
    "Robert",
    "Sarah", // 1
    "Scott",

    "Armand",
    "Bernard",
    "Claude",
    "Danielle", // 1
    "Emile",
    "Gaston",
    "Gerard",
    "Henri",
    "Jacqueline", // 1
    "Jacques",
    "Jean",
    "Leon",
    "Louis",
    "Marc",
    "Marcel",
    "Marielle", // 1
    "Micheline", // 1
    "Pierre",
    "Rene",
    "Sylvie", // 1

    "Christel", // 1
    "Dieter",
    "Franz",
    "Gerhard",
    "Gudrun", // 1
    "Gunter",
    "Hans",
    "Helga", // 1
    "Jurgen",
    "Karin", // 1
    "Klaus",
    "Manfred",
    "Matthias",
    "Otto",
    "Rudi",
    "Siegfried",
    "Stefan",
    "Uta", // 1
    "Werner",
    "Wolfgang",

    "Akinori",
    "Isao",
    "Jungo",
    "Hideo",
    "Kenji",
    "Mariko", // 1
    "Masaharu",
    "Masanori",
    "Michiko", // 1
    "Naohiro",
    "Sata", // 1
    "Shigeo",
    "Shigeru",
    "Shuji",
    "Sumie", // 1
    "Tatsuo",
    "Toshio",
    "Yasuaki",
    "Yataka",
    "Yoko", // 1
    "Yuzo",

    "Anatoly",
    "Andrei",
    "Alyona", // 1
    "Boris",
    "Dmitriy",
    "Galina", // 1
    "Gennadiy",
    "Grigoriy",
    "Igor",
    "Ivan",
    "Leonid",
    "Lyudmila", // 1
    "Mikhail",
    "Natalya", // 1
    "Nikolai",
    "Olga", // 1
    "Sergei",
    "Tatyana", // 1
    "Victor",
    "Vladimir",
    "Yuri",
    ];

  static var surnames: Array<String> = [
    "Bradley",
    "Bryant",
    "Carr",
    "Crossett",
    "Dodge",
    "Gallagher",
    "Homburger",
    "Horton",
    "Hudson",
    "Johnson",
    "Kemp",
    "King",
    "McNeil",
    "Miller",
    "Mitchell",
    "Nash",
    "Stephens",
    "Stoddard",
    "Thompson",
    "Webb",

    "Bailey",
    "Blake",
    "Carter",
    "Davies",
    "Day",
    "Evans",
    "Hill",
    "Jones",
    "Jonlan",
    "Martin",
    "Parker",
    "Pearce",
    "Reynolds",
    "Robinson",
    "Sharpe",
    "Smith",
    "Stewart",
    "Taylor",
    "Watson",
    "White",
    "Wright",

    "Bouissou",
    "Bouton",
    "Buchard",
    "Coicaud",
    "Collignon",
    "Cuvelier",
    "Dagallier",
    "Dreyfus",
    "Dujardin",
    "Gaudin",
    "Gautier",
    "Gressier",
    "Guerin",
    "Laroyenne",
    "Lecointe",
    "Lefevre",
    "Luget",
    "Marcelle",
    "Pecheux",
    "Revenu",

    "Berger",
    "Brehme",
    "Esser",
    "Faerber",
    "Geisler",
    "Gunkel",
    "Hafner",
    "Heinsch",
    "Keller",
    "Krause",
    "Mederow",
    "Meyer",
    "Richter",
    "Schultz",
    "Seidler",
    "Steinbach",
    "Ulbricht",
    "Unger",
    "Vogel",
    "Zander",

    "Akira",
    "Fujimoto",
    "Ishii",
    "Iwahara",
    "Iwasaki",
    "Kojima",
    "Koyama",
    "Matsumara",
    "Morita",
    "Noguchi",
    "Okabe",
    "Okamoto",
    "Sato",
    "Shimaoka",
    "Shoji",
    "Tanida",
    "Tanikawa",
    "Yamanaka",
    "Yamashita",
    "Yamazaki",

    "Andryanov",
    "Belov",
    "Chukarin",
    "Gorokhov",
    "Kolotov",
    "Korkin",
    "Likhachev",
    "Maleev",
    "Mikhailov",
    "Petrov",
    "Razuvaev",
    "Romanov",
    "Samchenko",
    "Scharov",
    "Shadrin",
    "Shalimov",
    "Torbin",
    "Voronin",
    "Yakubchik",
    "Zhdanovich",
    ];
}
