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
        Sprite InsigniaoftheCorhazi = Resources.Load<Sprite>("Images/ga_id_15");
        Sprite ArisannaHerbalistProdigy_0 = Resources.Load<Sprite>("Images/ga_id_16");
        Sprite ArisannaHerbalistProdigy_1 = Resources.Load<Sprite>("Images/ga_id_16a");
        Sprite LorraineWanderingWarrior_0 = Resources.Load<Sprite>("Images/ga_id_17");
        Sprite LorraineWanderingWarrior_1 = Resources.Load<Sprite>("Images/ga_id_17a");
        Sprite TristanUnderhanded_0 = Resources.Load<Sprite>("Images/ga_id_18");
        Sprite TristanUnderhanded_1 = Resources.Load<Sprite>("Images/ga_id_18a");
        Sprite MerlinKingslayer_0 = Resources.Load<Sprite>("Images/ga_id_19");
        Sprite MerlinKingslayer_1 = Resources.Load<Sprite>("Images/ga_id_19a");
        Sprite MerlinKingslayer_2 = Resources.Load<Sprite>("Images/ga_id_19b");
        




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

        cardList.Add(new Card(
            17, //id
            new List<string> { "REGALIA", "ITEM" }, //Types
            new List<string> { "ASSASSIN" }, //Classes
            new List<string> { "ASSASSIN", "ARTIFACT" }, //SubTypes
            "LUXEM", //Element
            "Insignia of the Corhazi", //Name
            "(3),REST : Put a preparation counter on your champion.\r\n\r\n" +
            "Class BonusWhenever you activate a prepared card while your influence is six or less, draw a card into your memory.", //Effect
            false,//isToken
            0,//CostMemory
            null,//CostReserve
            null,//level
            null,//Life
            null,//Durability
            null,//Speed
            InsigniaoftheCorhazi)); //Image

        cardList.Add(new Card(
            18, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "CLERIC" }, //Classes
            new List<string> { "CLERIC", "HUMAN" }, //SubTypes
            "NORM", //Element
            "Arisanna, Herbalist Prodigy", //Name
            "On Enter: Gather twice. " +
            "(To gather, summon a Blightroot, Manaroot, Silvershine, Fraysia, Razorvine, or Springleaf token, chosen at random.)", //Effect
            false,//isToken
            1,//CostMemory
            null,//CostReserve
            1,//level
            19,//Life
            null,//Durability
            null,//Speed
            ArisannaHerbalistProdigy_0)); //Image

        cardList.Add(new Card(
            19, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "CLERIC" }, //Classes
            new List<string> { "CLERIC", "HUMAN" }, //SubTypes
            "NORM", //Element
            "Arisanna, Herbalist Prodigy", //Name
            "On Enter: Gather twice. " +
            "(To gather, summon a Blightroot, Manaroot, Silvershine, Fraysia, Razorvine, or Springleaf token, chosen at random.)", //Effect
            false,//isToken
            1,//CostMemory
            null,//CostReserve
            1,//level
            19,//Life
            null,//Durability
            null,//Speed
            ArisannaHerbalistProdigy_1)); //Image

        cardList.Add(new Card(
            20, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "WARRIOR" }, //Classes
            new List<string> { "WARRIOR", "HUMAN" }, //SubTypes
            "NORM", //Element
            "Lorraine, Wandering Warrior", //Name
            "On Enter: Materialize a weapon card with memory cost 0 from your material deck.)", //Effect
            false,//isToken
            1,//CostMemory
            null,//CostReserve
            1,//level
            20,//Life
            null,//Durability
            null,//Speed
            LorraineWanderingWarrior_0)); //Image

        cardList.Add(new Card(
            21, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "WARRIOR" }, //Classes
            new List<string> { "WARRIOR", "HUMAN" }, //SubTypes
            "NORM", //Element
            "Lorraine, Wandering Warrior", //Name
            "On Enter: Materialize a weapon card with memory cost 0 from your material deck.", //Effect
            false,//isToken
            1,//CostMemory
            null,//CostReserve
            1,//level
            20,//Life
            null,//Durability
            null,//Speed
            LorraineWanderingWarrior_1)); //Image

        cardList.Add(new Card(
            22, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "ASSASSIN" }, //Classes
            new List<string> { "ASSASSIN", "HUMAN" }, //SubTypes
            "NORM", //Element
            "Tristan, Underhanded", //Name
            "On Enter: You may put a preparation  counter on Tristan. If you don’t, you gain agility 3 for this turn. " +
            "(Agility 3 — Return three cards from your memory to your hand at the beginning of the end phase.)", //Effect
            false,//isToken
            1,//CostMemory
            null,//CostReserve
            1,//level
            19,//Life
            null,//Durability
            null,//Speed
            TristanUnderhanded_0)); //Image

        cardList.Add(new Card(
            23, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "ASSASSIN" }, //Classes
            new List<string> { "ASSASSIN", "HUMAN" }, //SubTypes
            "NORM", //Element
            "Tristan, Underhanded", //Name
            "On Enter: You may put a preparation  counter on Tristan. If you don’t, you gain agility 3 for this turn. " +
            "(Agility 3 — Return three cards from your memory to your hand at the beginning of the end phase.)", //Effect
            false,//isToken
            1,//CostMemory
            null,//CostReserve
            1,//level
            19,//Life
            null,//Durability
            null,//Speed
            TristanUnderhanded_1)); //Image

        cardList.Add(new Card(
            24, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "MAGE", "WARRIOR" }, //Classes
            new List<string> { "MAGE", "WARRIOR", "HUMAN" }, //SubTypes
            "CRUX", //Element
            "Merlin, Kingslayer", //Name
            "Merlin Lineage\r\n\r\n" +
            "At the beginning of your recollection phase, put a level counter on Merlin. " +
            "Then, if there's an even amount of level counters on Merlin, draw a card and Merlin's attacks get +2(ATTACK) until end of turn.", //Effect
            false,//isToken
            3,//CostMemory
            null,//CostReserve
            3,//level
            28,//Life
            null,//Durability
            null,//Speed
            MerlinKingslayer_0)); //Image

        cardList.Add(new Card(
            25, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "MAGE", "WARRIOR" }, //Classes
            new List<string> { "MAGE", "WARRIOR", "HUMAN" }, //SubTypes
            "CRUX", //Element
            "Merlin, Kingslayer", //Name
            "Merlin Lineage\r\n\r\n" +
            "At the beginning of your recollection phase, put a level counter on Merlin. " +
            "Then, if there's an even amount of level counters on Merlin, draw a card and Merlin's attacks get +2(ATTACK) until end of turn.", //Effect
            false,//isToken
            3,//CostMemory
            null,//CostReserve
            3,//level
            28,//Life
            null,//Durability
            null,//Speed
            MerlinKingslayer_1)); //Image

        cardList.Add(new Card(
            26, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "MAGE", "WARRIOR" }, //Classes
            new List<string> { "MAGE", "WARRIOR", "HUMAN" }, //SubTypes
            "CRUX", //Element
            "Merlin, Kingslayer", //Name
            "Merlin Lineage\r\n\r\n" +
            "At the beginning of your recollection phase, put a level counter on Merlin. " +
            "Then, if there's an even amount of level counters on Merlin, draw a card and Merlin's attacks get +2(ATTACK) until end of turn.", //Effect
            false,//isToken
            3,//CostMemory
            null,//CostReserve
            3,//level
            28,//Life
            null,//Durability
            null,//Speed
            MerlinKingslayer_2)); //Image
    }
}
