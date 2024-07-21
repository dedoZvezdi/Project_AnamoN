using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CardDatabase : MonoBehaviour
{
    public static List<Card> cardList = new List<Card>();


    void Awake()
    {
        Sprite ApotheosisRite = Resources.Load<Sprite>("Images/ga_id_1");
        Sprite SpiritofFire_0 = Resources.Load<Sprite>("Images/ga_id_2");
        Sprite SpiritofFire_1 = Resources.Load<Sprite>("Images/ga_id_2a");
        Sprite LostSpirit = Resources.Load<Sprite>("Images/ga_id_3");
        Sprite SpiritofSlime = Resources.Load<Sprite>("Images/ga_id_4");
        Sprite SpiritofSereneFire = Resources.Load<Sprite>("Images/ga_id_5");
        Sprite FragmentedSpiritofFire = Resources.Load<Sprite>("Images/ga_id_6");
        Sprite ScepterofLumina = Resources.Load<Sprite>("Images/ga_id_7");
        Sprite SpiritofWater_0 = Resources.Load<Sprite>("Images/ga_id_8");
        Sprite SpiritofWater_1 = Resources.Load<Sprite>("Images/ga_id_8a");
        Sprite SpiritofSereneWater = Resources.Load<Sprite>("Images/ga_id_9");
        Sprite FragmentedSpiritofWater = Resources.Load<Sprite>("Images/ga_id_10");
        Sprite StonescaleBand = Resources.Load<Sprite>("Images/ga_id_11");
        Sprite SpiritofWind_0 = Resources.Load<Sprite>("Images/ga_id_12");
        Sprite SpiritofWind_1 = Resources.Load<Sprite>("Images/ga_id_12a");
        Sprite SpiritofSereneWind = Resources.Load<Sprite>("Images/ga_id_13");
        Sprite FragmentedSpiritofWind = Resources.Load<Sprite>("Images/ga_id_14");


        cardList.Add(new Card(
            0, //id
            new List<string> { "REGALIA", "ITEM" },//Types
            new List<string> { "WARRIOR"}, //Classes
            new List<string> { "WARRIOR", "Ring" }, //SubTypes
            "NORM",//Element
            "Apotheosis Rite",//Name
            "Divine Relic\r\n\r\nBanish Apotheosis Rite: " +
            "Your champion becomes an Ascendant in addition to its other types. Draw a card.",//Effect
            false,//isToken
            0,//CostMemory
            null,//CostReserve
            null,//level
            null,//Life
            null,//Durability
            null,//Speed
            ApotheosisRite));//Image

        
        cardList.Add(new Card(
            1, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "SPIRIT" }, //Classes
            new List<string> { "SPIRIT" }, //SubTypes
            "FIRE", //Element
            "Spirit of Fire", //Name
            "On Enter: Draw seven cards.", //Effect
            false,//isToken
            0,//CostMemory
            null,//CostReserve
            0,//level
            15,//Life
            null,//Durability
            null,//Speed
            SpiritofFire_0)); //Image

        cardList.Add(new Card(
            2, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "SPIRIT" }, //Classes
            new List<string> { "SPIRIT" }, //SubTypes
            "FIRE", //Element
            "Spirit of Fire", //Name
            "On Enter: Draw seven cards.", //Effect
            false,//isToken
            0,//CostMemory
            null,//CostReserve
            0,//level
            15,//Life
            null,//Durability
            null,//Speed
            SpiritofFire_1)); //Image

        cardList.Add(new Card(
            3, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "SPIRIT" }, //Classes
            new List<string> { "SPIRIT" }, //SubTypes
            "NORM", //Element
            "Lost Spirit", //Name
            "On Enter: Draw seven cards.", //Effect
            false,//isToken
            0,//CostMemory
            null,//CostReserve
            0,//level
            15,//Life
            null,//Durability
            null,//Speed
            LostSpirit)); //Image

        cardList.Add(new Card(
            4, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "SPIRIT" }, //Classes
            new List<string> { "SPIRIT" }, //SubTypes
            "NORM", //Element
            "Spirit of SLime", //Name
            "On Enter: Draw seven cards.\r\n\r\nInherited Effect: " +
            "Ignore the elemental requirements of basic element Slime cards you activate", //Effect
            false,//isToken
            0,//CostMemory
            null,//CostReserve
            0,//level
            15,//Life
            null,//Durability
            null,//Speed
            SpiritofSlime)); //Image

        cardList.Add(new Card(
            5, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "SPIRIT" }, //Classes
            new List<string> { "SPIRIT" }, //SubTypes
            "FIRE", //Element
            "Spirit of Serene Fire", //Name
            "On Enter: Glimpse 6. Draw six cards.\r\n\r\nLineage Release — Recover 6. " +
            "(Activate this ability by banishing this card from your champion's inner lineage.)", //Effect
            false,//isToken
            0,//CostMemory
            null,//CostReserve
            0,//level
            15,//Life
            null,//Durability
            null,//Speed
            SpiritofSereneFire)); //Image

        cardList.Add(new Card(
            6, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "SPIRIT" }, //Classes
            new List<string> { "SPIRIT" }, //SubTypes
            "FIRE", //Element
            "Fragmented Spirit of Fire", //Name
            "On Enter: Glimpse 6. Draw six cards. Then summon a Spirit Shard token.", //Effect
            false,//isToken
            0,//CostMemory
            null,//CostReserve
            0,//level
            15,//Life
            null,//Durability
            null,//Speed
            FragmentedSpiritofFire)); //Image

        cardList.Add(new Card(
            7, //id
            new List<string> { "REGALIA", "ITEM" }, //Types
            new List<string> { "CLERIC" }, //Classes
            new List<string> { "CLERIC", "SCEPTER" }, //SubTypes
            "WATER", //Element
            "Scepter of Lumina", //Name
            "As long as each player controls a water element champion, you may activate this card from your material deck. " +
            "(You still pay its costs.)\r\n\r\nWhenever your champion levels up, deal 4 damage to target champion you don't control." +
            "\r\n\r\n(5), Banish Scepter of Lumina: Draw two cards.", //Effect
            false,//isToken
            1,//CostMemory
            null,//CostReserve
            null,//level
            null,//Life
            null,//Durability
            null,//Speed
            ScepterofLumina)); //Image

        cardList.Add(new Card(
            8, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "SPIRIT" }, //Classes
            new List<string> { "SPIRIT" }, //SubTypes
            "WATER", //Element
            "Spirit of Water", //Name
            "On Enter: Draw seven cards.", //Effect
            false,//isToken
            0,//CostMemory
            null,//CostReserve
            0,//level
            15,//Life
            null,//Durability
            null,//Speed
            SpiritofWater_0)); //Image

        cardList.Add(new Card(
            9, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "SPIRIT" }, //Classes
            new List<string> { "SPIRIT" }, //SubTypes
            "WATER", //Element
            "Spirit of Water", //Name
            "On Enter: Draw seven cards.", //Effect
            false,//isToken
            0,//CostMemory
            null,//CostReserve
            0,//level
            15,//Life
            null,//Durability
            null,//Speed
            SpiritofWater_1)); //Image

        cardList.Add(new Card(
            10, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "SPIRIT" }, //Classes
            new List<string> { "SPIRIT" }, //SubTypes
            "WATER", //Element
            "Spirit of Serene Water", //Name
            "On Enter: Glimpse 6. Draw six cards.\r\n\r\nLineage Release — Recover 6. " +
            "(Activate this ability by banishing this card from your champion's inner lineage.)", //Effect
            false,//isToken
            0,//CostMemory
            null,//CostReserve
            0,//level
            15,//Life
            null,//Durability
            null,//Speed
            SpiritofSereneWater)); //Image

        cardList.Add(new Card(
            11, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "SPIRIT" }, //Classes
            new List<string> { "SPIRIT" }, //SubTypes
            "WATER", //Element
            "Fragmented Spirit of Water", //Name
            "On Enter: Glimpse 6. Draw six cards. Then summon a Spirit Shard token.", //Effect
            false,//isToken
            0,//CostMemory
            null,//CostReserve
            0,//level
            15,//Life
            null,//Durability
            null,//Speed
            FragmentedSpiritofWater)); //Image

        cardList.Add(new Card(
            12, //id
            new List<string> { "REGALIA", "ITEM" }, //Types
            new List<string> { "TAMER" }, //Classes
            new List<string> { "TAMER", "ARTIFACT" }, //SubTypes
            "TERA", //Element
            "Stonescale Band", //Name
            "Class BonusOn Enter: Discard up to three ally cards from your hand and/or memory, then draw that many cards." +
            "\r\n\r\n(1),REST : Until end of turn, you may activate ally cards as though they had fast activation.", //Effect
            false,//isToken
            0,//CostMemory
            null,//CostReserve
            null,//level
            null,//Life
            null,//Durability
            null,//Speed
            StonescaleBand)); //Image

        cardList.Add(new Card(
            13, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "SPIRIT" }, //Classes
            new List<string> { "SPIRIT" }, //SubTypes
            "WIND", //Element
            "Spirit of Wind", //Name
            "On Enter: Draw seven cards.", //Effect
            false,//isToken
            0,//CostMemory
            null,//CostReserve
            0,//level
            15,//Life
            null,//Durability
            null,//Speed
            SpiritofWind_0)); //Image

        cardList.Add(new Card(
            14, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "SPIRIT" }, //Classes
            new List<string> { "SPIRIT" }, //SubTypes
            "WIND", //Element
            "Spirit of Wind", //Name
            "On Enter: Draw seven cards.", //Effect
            false,//isToken
            0,//CostMemory
            null,//CostReserve
            0,//level
            15,//Life
            null,//Durability
            null,//Speed
            SpiritofWind_1)); //Image

        cardList.Add(new Card(
            15, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "SPIRIT" }, //Classes
            new List<string> { "SPIRIT" }, //SubTypes
            "WIND", //Element
            "Spirit of Serene Wind", //Name
            "On Enter: Glimpse 6. Draw six cards.\r\n\r\nLineage Release — Recover 6. " +
            "(Activate this ability by banishing this card from your champion's inner lineage.)", //Effect
            false,//isToken
            0,//CostMemory
            null,//CostReserve
            0,//level
            15,//Life
            null,//Durability
            null,//Speed
            SpiritofSereneWind)); //Image

        cardList.Add(new Card(
            16, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "SPIRIT" }, //Classes
            new List<string> { "SPIRIT" }, //SubTypes
            "WIND", //Element
            "Fragmented Spirit of Wind", //Name
            "On Enter: Glimpse 6. Draw six cards. Then summon a Spirit Shard token.", //Effect
            false,//isToken
            0,//CostMemory
            null,//CostReserve
            0,//level
            15,//Life
            null,//Durability
            null,//Speed
            FragmentedSpiritofWind)); //Image
    }
}
