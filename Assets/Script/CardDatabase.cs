using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CardDatabase : MonoBehaviour
{
    public static List<Card> cardList = new List<Card>();


    void Awake()
    {
        Sprite ApotheosisRite_0 = Resources.Load<Sprite>("Images/ga_id_1");
        Sprite SpiritofFire_0 = Resources.Load<Sprite>("Images/ga_id_2");


        cardList.Add(new Card(
            0, //id
            new List<string> { "Regalia Item" },//Types
            new List<string> { "Warrior", }, //Classes
            new List<string> { "Warrior", "Ring" }, //SubTypes
            "NORM",//Element
            "Apotheosis Rite",//Name
            "Divine Relic   Banish Apotheosis Rite: Your champion becomes an Ascendant in addition to its other types. Draw a card.",//Effect
            null,//Flavor
            0,//CostMemory
            null,//CostReserve
            null,//level
            null,//Life
            null,//Durability
            null,//Speed
            ApotheosisRite_0));//Image

        
        cardList.Add(new Card(
            1, //id
            new List<string> { "Champion" }, //Types
            new List<string> { "Spirit" }, //Classes
            new List<string> { "Spirit" }, //SubTypes
            "FIRE", //Element
            "Apotheosis Rite", //Name
            "On Enter: Draw seven cards.", //Effect
            "The leyline within Flagma flares to life once more, bathing intrepid souls in a fiery vortex of might.",//Flavor
            0,//CostMemory
            null,//CostReserve
            0,//level
            15,//Life
            null,//Durability
            null,//Speed
            SpiritofFire_0)); //Image
    }
}
