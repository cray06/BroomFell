class_name Changelog
extends RefCounted

const ENTRIES: Array[Dictionary] = [
	{
		"version": "v0.3",
		"date": "31/10/2026",
		"changes": [
			"Niveaux de 15 minutes avec un compte à rebours",
			"Le Roi Gluant arrive à la fin du temps",
			"Après le boss : mode survie, le temps passe en négatif et les monstres deviennent de plus en plus nombreux et forts",
			"Difficulté qui augmente tout au long du niveau",
			"Bouton pause pour continuer ou revenir au menu",
			"La partie se met en pause si on quitte l'application",
			"Écran d'accueil épuré : la carte de profil et le coffre à or sont retirés",
			"Nouvelles icônes dessinées pour la barre de navigation et les menus",
			"La visée automatique ne cible que les monstres visibles à l'écran",
			"Cartes de montée de niveau mieux espacées",
		],
	},
	{
		"version": "v0.2",
		"date": "31/10/2026",
		"changes": [
			"Nouvel écran d'accueil : profil, coffre et barre de navigation",
			"Sélection de niveau sur des îles, avec 3 niveaux par île",
			"Coffre gratuit qui rapporte de l'or toutes les 2 heures",
			"Visée automatique sur le monstre le plus proche",
			"Gros gain de performances quand beaucoup de cristaux sont au sol",
			"Les cristaux en trop fusionnent en gros cristaux dorés",
			"Nouveau sprite pour la sorcière",
		],
	},
	{
		"version": "v0.1",
		"date": "30/10/2026",
		"changes": [
			"Première version jouable de BroomFell",
			"11 sorts et 14 augments à combiner",
			"Hordes de slimes et combat contre le Roi Gluant",
			"Bonus au sol : aimant, bombe, sablier, rage, bulle, cœur",
			"Meilleur score sauvegardé",
			"Version Android disponible en APK",
		],
	},
]


static func current_version() -> String:
	return ENTRIES[0].version
