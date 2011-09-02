/**************************************************************************
 *                        RTD Trinkets                         			 *
 *																		 *
 *It's in a include so that it is easier to work in Pawn Studio so that  *
 *when I'm typing it pops up :)                                          *
 *																		 *
 **************************************************************************/

 #if defined _rtd_trinkets_included
 #endinput
#endif
#define _rtd_trinkets_included

//make sure to update this everytime a trinket is added
//
//NOTE!!!
//trinkets are hard coded to have a database maximum of 50.
//
//MAX_TRINKETS represents the number of trinkets available
#define MAX_TRINKETS		9

#define TRINKET_LADYLUCK			0
#define TRINKET_DICEMINER			1
#define TRINKET_PARTYTIME			2
#define TRINKET_UNUSUALMELEE		3
#define TRINKET_SCARYTAUNT		4
#define TRINKET_EXPLOSIVEDEATH	5
#define TRINKET_QUICKDRAW			6
#define TRINKET_HEAVYHITTER		7
#define TRINKET_SUPERJUMP			8

new String:trinket_id[MAX_TRINKETS][32]; //roll identifiers that match up with ;

stock SetupTrinket_IDs()
{
	////////////////////////////////////
	// Setup for proper indexing when //
	// reading from config            //
	////////////////////////////////////
	Format(trinket_id[TRINKET_LADYLUCK], 		32, "LADYLUCK");
	Format(trinket_id[TRINKET_DICEMINER], 		32, "DICEMINER");
	Format(trinket_id[TRINKET_PARTYTIME], 		32, "PARTYTIME");
	Format(trinket_id[TRINKET_UNUSUALMELEE], 	32, "UNUSUALMELEE");
	Format(trinket_id[TRINKET_SCARYTAUNT], 		32, "SCARYTAUNT");
	Format(trinket_id[TRINKET_EXPLOSIVEDEATH], 	32, "EXPLOSIVEDEATH");
	Format(trinket_id[TRINKET_QUICKDRAW], 		32, "QUICKDRAW");
	Format(trinket_id[TRINKET_HEAVYHITTER], 	32, "HEAVYHITTER");
	Format(trinket_id[TRINKET_SUPERJUMP], 			32, "SUPERJUMP");
}