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
        Sprite TristanShadowdancer_0 = Resources.Load<Sprite>("Images/ga_id_20");
        Sprite TristanShadowdancer_1 = Resources.Load<Sprite>("Images/ga_id_20a");
        Sprite SilvieSlimeSovereign_0 = Resources.Load<Sprite>("Images/ga_id_21");
        Sprite SilvieSlimeSovereign_1 = Resources.Load<Sprite>("Images/ga_id_21a");
        Sprite ArisannaMasterAlchemist_0 = Resources.Load<Sprite>("Images/ga_id_22");
        Sprite ArisannaMasterAlchemist_1 = Resources.Load<Sprite>("Images/ga_id_22a");
        Sprite ArisannaMasterAlchemist_2 = Resources.Load<Sprite>("Images/ga_id_22b");
        Sprite LorraineBlademaster_0 = Resources.Load<Sprite>("Images/ga_id_23");
        Sprite LorraineBlademaster_1 = Resources.Load<Sprite>("Images/ga_id_23a");
        Sprite LorraineBlademaster_2 = Resources.Load<Sprite>("Images/ga_id_23b");
        Sprite LorraineCruxKnight_0 = Resources.Load<Sprite>("Images/ga_id_24");
        Sprite LorraineCruxKnight_1 = Resources.Load<Sprite>("Images/ga_id_24a");
        Sprite LorraineCruxKnight_2 = Resources.Load<Sprite>("Images/ga_id_24b");
        Sprite TristanHiredBlade_0 = Resources.Load<Sprite>("Images/ga_id_25");
        Sprite TristanHiredBlade_1 = Resources.Load<Sprite>("Images/ga_id_25a");
        Sprite AzureProtectiveTrinket = Resources.Load<Sprite>("Images/ga_id_26");
        Sprite AssassinsMantle = Resources.Load<Sprite>("Images/ga_id_27");
        Sprite ZanderDeftExecutor_0 = Resources.Load<Sprite>("Images/ga_id_28");
        Sprite ZanderDeftExecutor_1 = Resources.Load<Sprite>("Images/ga_id_28a");
        Sprite ArisannaAstralZenith_0 = Resources.Load<Sprite>("Images/ga_id_29");
        Sprite ArisannaAstralZenith_1 = Resources.Load<Sprite>("Images/ga_id_29a");
        Sprite LorraineSpiritRuler_0 = Resources.Load<Sprite>("Images/ga_id_30");
        Sprite LorraineSpiritRuler_1 = Resources.Load<Sprite>("Images/ga_id_30a");
        Sprite CrimsonProtectiveTrinket = Resources.Load<Sprite>("Images/ga_id_31");
        Sprite TristanShadowreaver_0 = Resources.Load<Sprite>("Images/ga_id_32");
        Sprite TristanShadowreaver_1 = Resources.Load<Sprite>("Images/ga_id_32a");
        Sprite ArisannaLucentArbiter_0 = Resources.Load<Sprite>("Images/ga_id_33");
        Sprite ArisannaLucentArbiter_1 = Resources.Load<Sprite>("Images/ga_id_33a");
        Sprite RaiSpellcrafter_0 = Resources.Load<Sprite>("Images/ga_id_34");
        Sprite RaiSpellcrafter_1 = Resources.Load<Sprite>("Images/ga_id_34a");
        Sprite Alkahest = Resources.Load<Sprite>("Images/ga_id_35");
        Sprite QuicksilverGrail = Resources.Load<Sprite>("Images/ga_id_36");
        Sprite DianaKeenHuntress_0 = Resources.Load<Sprite>("Images/ga_id_37");
        Sprite DianaKeenHuntress_1 = Resources.Load<Sprite>("Images/ga_id_37a");
        Sprite RaiArchmage_0 = Resources.Load<Sprite>("Images/ga_id_38");
        Sprite RaiArchmage_1 = Resources.Load<Sprite>("Images/ga_id_38a");
        Sprite RaiStormSeer_0 = Resources.Load<Sprite>("Images/ga_id_39");
        Sprite RaiStormSeer_1 = Resources.Load<Sprite>("Images/ga_id_39a");
        Sprite RaiStormSeer_2 = Resources.Load<Sprite>("Images/ga_id_39b");
        Sprite TariffRing = Resources.Load<Sprite>("Images/ga_id_40");
        Sprite BackupCharger = Resources.Load<Sprite>("Images/ga_id_41");
        Sprite KeySlimePudding = Resources.Load<Sprite>("Images/ga_id_42");
        Sprite DianaDeadlyDuelist_0 = Resources.Load<Sprite>("Images/ga_id_43");
        Sprite DianaDeadlyDuelist_1 = Resources.Load<Sprite>("Images/ga_id_43a");
        Sprite DianaDeadlyDuelist_2 = Resources.Load<Sprite>("Images/ga_id_43b");
        Sprite RaiManaWeaver_0 = Resources.Load<Sprite>("Images/ga_id_44");
        Sprite RaiManaWeaver_1 = Resources.Load<Sprite>("Images/ga_id_44a");
        Sprite SilvieLovedbyAll_0 = Resources.Load<Sprite>("Images/ga_id_45");
        Sprite SilvieLovedbyAll_1 = Resources.Load<Sprite>("Images/ga_id_45a");
        Sprite TitheProclamation_0 = Resources.Load<Sprite>("Images/ga_id_46");
        Sprite TitheProclamation_1 = Resources.Load<Sprite>("Images/ga_id_46a");
        Sprite GearstrideGloves = Resources.Load<Sprite>("Images/ga_id_47");
        Sprite ClockworkMusicbox = Resources.Load<Sprite>("Images/ga_id_48");
        Sprite AithneSpiritofFire = Resources.Load<Sprite>("Images/ga_id_49");
        Sprite DianaCursebreaker_0 = Resources.Load<Sprite>("Images/ga_id_50");
        Sprite DianaCursebreaker_1 = Resources.Load<Sprite>("Images/ga_id_50a");
        Sprite SilvieWildsWhisperer_0 = Resources.Load<Sprite>("Images/ga_id_51");
        Sprite SilvieWildsWhisperer_1 = Resources.Load<Sprite>("Images/ga_id_51a");
        Sprite ZanderBlindingSteel_0 = Resources.Load<Sprite>("Images/ga_id_52");
        Sprite ZanderBlindingSteel_1 = Resources.Load<Sprite>("Images/ga_id_52a");
        Sprite ViridianProtectiveTrinket_0 = Resources.Load<Sprite>("Images/ga_id_53");
        Sprite ViridianProtectiveTrinket_1 = Resources.Load<Sprite>("Images/ga_id_53a");
        Sprite FrameworkSidearm = Resources.Load<Sprite>("Images/ga_id_54");
        Sprite SlimeNexus = Resources.Load<Sprite>("Images/ga_id_55");
        Sprite DusksoulStone = Resources.Load<Sprite>("Images/ga_id_56");
        Sprite MorriganLostSpirit = Resources.Load<Sprite>("Images/ga_id_57");
        Sprite DianaDuskstalker_0 = Resources.Load<Sprite>("Images/ga_id_58");
        Sprite DianaDuskstalker_1 = Resources.Load<Sprite>("Images/ga_id_58a");
        Sprite SilvieWiththePack_0 = Resources.Load<Sprite>("Images/ga_id_59");
        Sprite SilvieWiththePack_1 = Resources.Load<Sprite>("Images/ga_id_59a");
        Sprite BeastsoulVisage = Resources.Load<Sprite>("Images/ga_id_60");
        Sprite MercenarysBlade = Resources.Load<Sprite>("Images/ga_id_61");
        Sprite MalignantAthame = Resources.Load<Sprite>("Images/ga_id_62");
        Sprite SlimeTotem = Resources.Load<Sprite>("Images/ga_id_63");
        Sprite PrismaticSpirit = Resources.Load<Sprite>("Images/ga_id_64");
        Sprite TonorisLoneMercenary_0 = Resources.Load<Sprite>("Images/ga_id_65");
        Sprite TonorisLoneMercenary_1 = Resources.Load<Sprite>("Images/ga_id_65a");
        Sprite SilvieEarthTune_0 = Resources.Load<Sprite>("Images/ga_id_66");
        Sprite SilvieEarthTune_1 = Resources.Load<Sprite>("Images/ga_id_66a");
        Sprite ClarentSwordofPeace = Resources.Load<Sprite>("Images/ga_id_67");
        Sprite ExplosiveRune = Resources.Load<Sprite>("Images/ga_id_68");
        Sprite ShadebloodCoating = Resources.Load<Sprite>("Images/ga_id_69");
        Sprite VerdantScepter = Resources.Load<Sprite>("Images/ga_id_70");
        Sprite MercurialHeart = Resources.Load<Sprite>("Images/ga_id_71");

        cardList.Add(new Card(
            0, //id
            new List<string> { "REGALIA", "ITEM" },//Types
            new List<string> { "WARRIOR"}, //Classes
            new List<string> { "WARRIOR", "RING" }, //SubTypes
            "NORM",//Element
            "Apotheosis Rite",//Name
            "Divine Relic\r\n\r\nBanish Apotheosis Rite: " +
            "Your champion becomes an Ascendant in addition to its other types. Draw a card.",//Effect
            false,//Generated
            0,//CostMemory
            null,//CostReserve
            null,//level
            null,//Life
            null,//Power
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
            false,//Generated
            0,//CostMemory
            null,//CostReserve
            0,//level
            15,//Life
            null,//Power
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
            false,//Generated
            0,//CostMemory
            null,//CostReserve
            0,//level
            15,//Life
            null,//Power
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
            false,//Generated
            0,//CostMemory
            null,//CostReserve
            0,//level
            15,//Life
            null,//Power
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
            false,//Generated
            0,//CostMemory
            null,//CostReserve
            0,//level
            15,//Life
            null,//Power
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
            false,//Generated
            0,//CostMemory
            null,//CostReserve
            0,//level
            15,//Life
            null,//Power
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
            false,//Generated
            0,//CostMemory
            null,//CostReserve
            0,//level
            15,//Life
            null,//Power
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
            false,//Generated
            1,//CostMemory
            null,//CostReserve
            null,//level
            null,//Life
            null,//Power
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
            false,//Generated
            0,//CostMemory
            null,//CostReserve
            0,//level
            15,//Life
            null,//Power
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
            false,//Generated
            0,//CostMemory
            null,//CostReserve
            0,//level
            15,//Life
            null,//Power
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
            false,//Generated
            0,//CostMemory
            null,//CostReserve
            0,//level
            15,//Life
            null,//Power
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
            false,//Generated
            0,//CostMemory
            null,//CostReserve
            0,//level
            15,//Life
            null,//Power
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
            "(Class Bonus) On Enter: Discard up to three ally cards from your hand and/or memory, then draw that many cards." +
            "\r\n\r\n(1),REST : Until end of turn, you may activate ally cards as though they had fast activation.", //Effect
            false,//Generated
            0,//CostMemory
            null,//CostReserve
            null,//level
            null,//Life
            null,//Power
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
            false,//Generated
            0,//CostMemory
            null,//CostReserve
            0,//level
            15,//Life
            null,//Power
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
            false,//Generated
            0,//CostMemory
            null,//CostReserve
            0,//level
            15,//Life
            null,//Power
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
            false,//Generated
            0,//CostMemory
            null,//CostReserve
            0,//level
            15,//Life
            null,//Power
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
            false,//Generated
            0,//CostMemory
            null,//CostReserve
            0,//level
            15,//Life
            null,//Power
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
            "(Class Bonus) Whenever you activate a prepared card while your influence is six or less, draw a card into your memory.", //Effect
            false,//Generated
            0,//CostMemory
            null,//CostReserve
            null,//level
            null,//Life
            null,//Power
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
            false,//Generated
            1,//CostMemory
            null,//CostReserve
            1,//level
            19,//Life
            null,//Power
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
            false,//Generated
            1,//CostMemory
            null,//CostReserve
            1,//level
            19,//Life
            null,//Power
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
            false,//Generated
            1,//CostMemory
            null,//CostReserve
            1,//level
            20,//Life
            null,//Power
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
            false,//Generated
            1,//CostMemory
            null,//CostReserve
            1,//level
            20,//Life
            null,//Power
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
            false,//Generated
            1,//CostMemory
            null,//CostReserve
            1,//level
            19,//Life
            null,//Power
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
            false,//Generated
            1,//CostMemory
            null,//CostReserve
            1,//level
            19,//Life
            null,//Power
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
            "Then, if there's an even amount of level counters on Merlin, draw a card and Merlin's attacks get +2 POWER until end of turn.", //Effect
            false,//Generated
            3,//CostMemory
            null,//CostReserve
            3,//level
            28,//Life
            null,//Power
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
            "Then, if there's an even amount of level counters on Merlin, draw a card and Merlin's attacks get +2 POWER until end of turn.", //Effect
            false,//Generated
            3,//CostMemory
            null,//CostReserve
            3,//level
            28,//Life
            null,//Power
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
            "Then, if there's an even amount of level counters on Merlin, draw a card and Merlin's attacks get +2 POWER until end of turn.", //Effect
            false,//Generated
            3,//CostMemory
            null,//CostReserve
            3,//level
            28,//Life
            null,//Power
            null,//Durability
            null,//Speed
            MerlinKingslayer_2)); //Image

        cardList.Add(new Card(
            27, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "ASSASSIN" }, //Classes
            new List<string> { "ASSASSIN", "HUMAN" }, //SubTypes
            "UMBRA", //Element
            "Tristan, Shadowdancer", //Name
            "Tristan Lineage\r\n\r\n" +
            "On Enter: Summon two Ominous Shadow tokens and put a preparation counter on Tristan.\r\n\r\n" +
            "Remove two preparation counters from Tristan: Change the target of an attack that targets Tristan to a phantasia ally you control.", //Effect
            false,//Generated
            3,//CostMemory
            null,//CostReserve
            3,//level
            25,//Life
            null,//Power
            null,//Durability
            null,//Speed
            TristanShadowdancer_0)); //Image

        cardList.Add(new Card(
            28, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "ASSASSIN" }, //Classes
            new List<string> { "ASSASSIN", "HUMAN" }, //SubTypes
            "UMBRA", //Element
            "Tristan, Shadowdancer", //Name
            "Tristan Lineage\r\n\r\n" +
            "On Enter: Summon two Ominous Shadow tokens and put a preparation counter on Tristan.\r\n\r\n" +
            "Remove two preparation counters from Tristan: Change the target of an attack that targets Tristan to a phantasia ally you control.", //Effect
            false,//Generated
            3,//CostMemory
            null,//CostReserve
            3,//level
            25,//Life
            null,//Power
            null,//Durability
            null,//Speed
            TristanShadowdancer_1)); //Image

        cardList.Add(new Card(
            29, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "TAMER" }, //Classes
            new List<string> { "TAMER", "HUMAN" }, //SubTypes
            "TERA", //Element
            "Silvie, Slime Sovereign", //Name
            "Silvie Lineage\r\n\r\n" +
            "On Enter: The next Slime ally card you activate this turn costs 2 less to activate and enters the field with two additional buff counters on it." +
            "\r\n\r\nIgnore the elemental requirements of advanced element Slime cards you activate.", //Effect
            false,//Generated
            3,//CostMemory
            null,//CostReserve
            3,//level
            25,//Life
            null,//Power
            null,//Durability
            null,//Speed
            SilvieSlimeSovereign_0)); //Image

        cardList.Add(new Card(
            30, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "TAMER" }, //Classes
            new List<string> { "TAMER", "HUMAN" }, //SubTypes
            "TERA", //Element
            "Silvie, Slime Sovereign", //Name
            "Silvie Lineage\r\n\r\n" +
            "On Enter: The next Slime ally card you activate this turn costs 2 less to activate and enters the field with two additional buff counters on it." +
            "\r\n\r\nIgnore the elemental requirements of advanced element Slime cards you activate.", //Effect
            false,//Generated
            3,//CostMemory
            null,//CostReserve
            3,//level
            25,//Life
            null,//Power
            null,//Durability
            null,//Speed
            SilvieSlimeSovereign_0)); //Image

        cardList.Add(new Card(
            31, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "CLERIC" }, //Classes
            new List<string> { "CLERIC", "HUMAN" }, //SubTypes
            "NORM", //Element
            "Arisanna, Master Alchemist", //Name
            "Arisanna Lineage\r\n\r\n" +
            "On Enter: Gather twice.\r\n\r\n" +
            "Inherited Effect: At the beginning of your end phase, you may sacrifice two Herbs with the same name. If you do, draw a card.", //Effect
            false,//Generated
            2,//CostMemory
            null,//CostReserve
            2,//level
            22,//Life
            null,//Power
            null,//Durability
            null,//Speed
            ArisannaMasterAlchemist_0)); //Image

        cardList.Add(new Card(
            32, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "CLERIC" }, //Classes
            new List<string> { "CLERIC", "HUMAN" }, //SubTypes
            "NORM", //Element
            "Arisanna, Master Alchemist", //Name
            "Arisanna Lineage\r\n\r\n" +
            "On Enter: Gather twice.\r\n\r\n" +
            "Inherited Effect: At the beginning of your end phase, you may sacrifice two Herbs with the same name. If you do, draw a card.", //Effect
            false,//Generated
            2,//CostMemory
            null,//CostReserve
            2,//level
            22,//Life
            null,//Power
            null,//Durability
            null,//Speed
            ArisannaMasterAlchemist_1)); //Image

        cardList.Add(new Card(
            33, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "CLERIC" }, //Classes
            new List<string> { "CLERIC", "HUMAN" }, //SubTypes
            "NORM", //Element
            "Arisanna, Master Alchemist", //Name
            "Arisanna Lineage\r\n\r\n" +
            "On Enter: Gather twice.\r\n\r\n" +
            "Inherited Effect: At the beginning of your end phase, you may sacrifice two Herbs with the same name. If you do, draw a card.", //Effect
            false,//Generated
            2,//CostMemory
            null,//CostReserve
            2,//level
            22,//Life
            null,//Power
            null,//Durability
            null,//Speed
            ArisannaMasterAlchemist_2)); //Image

        cardList.Add(new Card(
            34, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "WARRIOR" }, //Classes
            new List<string> { "WARRIOR", "HUMAN" }, //SubTypes
            "NORM", //Element
            "Lorraine, Blademaster", //Name
            "Lorraine Lineage\r\n\r\n" +
            "On Enter: Until end of turn, Lorraine's attacks get +2 POWER and gain \"On Kill: Draw a car\"", //Effect
            false,//Generated
            2,//CostMemory
            null,//CostReserve
            2,//level
            24,//Life
            null,//Power
            null,//Durability
            null,//Speed
            ArisannaMasterAlchemist_0)); //Image

        cardList.Add(new Card(
            35, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "WARRIOR" }, //Classes
            new List<string> { "WARRIOR", "HUMAN" }, //SubTypes
            "NORM", //Element
            "Lorraine, Blademaster", //Name
            "Lorraine Lineage\r\n\r\n" +
            "On Enter: Until end of turn, Lorraine's attacks get +2 POWER and gain \"On Kill: Draw a car\"", //Effect
            false,//Generated
            2,//CostMemory
            null,//CostReserve
            2,//level
            24,//Life
            null,//Power
            null,//Durability
            null,//Speed
            ArisannaMasterAlchemist_1)); //Image

        cardList.Add(new Card(
            36, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "WARRIOR" }, //Classes
            new List<string> { "WARRIOR", "HUMAN" }, //SubTypes
            "NORM", //Element
            "Lorraine, Blademaster", //Name
            "Lorraine Lineage\r\n\r\n" +
            "On Enter: Until end of turn, Lorraine's attacks get +2 POWER and gain \"On Kill: Draw a car\"", //Effect
            false,//Generated
            2,//CostMemory
            null,//CostReserve
            2,//level
            24,//Life
            null,//Power
            null,//Durability
            null,//Speed
            ArisannaMasterAlchemist_2)); //Image

        cardList.Add(new Card(
            37, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "WARRIOR" }, //Classes
            new List<string> { "WARRIOR", "HUMAN" }, //SubTypes
            "CRUX", //Element
            "Lorraine, Crux Knight", //Name
            "Lorraine Lineage\r\n\r\n" +
            "Lorraine's attacks get +1 POWER for each regalia weapon card in your banishment. ", //Effect
            false,//Generated
            3,//CostMemory
            null,//CostReserve
            3,//level
            28,//Life
            null,//Power
            null,//Durability
            null,//Speed
            LorraineCruxKnight_0)); //Image

        cardList.Add(new Card(
            38, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "WARRIOR" }, //Classes
            new List<string> { "WARRIOR", "HUMAN" }, //SubTypes
            "CRUX", //Element
            "Lorraine, Crux Knight", //Name
            "Lorraine Lineage\r\n\r\n" +
            "Lorraine's attacks get +1 POWER for each regalia weapon card in your banishment. ", //Effect
            false,//Generated
            3,//CostMemory
            null,//CostReserve
            3,//level
            28,//Life
            null,//Power
            null,//Durability
            null,//Speed
            LorraineCruxKnight_1)); //Image

        cardList.Add(new Card(
            39, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "WARRIOR" }, //Classes
            new List<string> { "WARRIOR", "HUMAN" }, //SubTypes
            "CRUX", //Element
            "Lorraine, Crux Knight", //Name
            "Lorraine Lineage\r\n\r\n" +
            "Lorraine's attacks get +1 POWER for each regalia weapon card in your banishment. ", //Effect
            false,//Generated
            3,//CostMemory
            null,//CostReserve
            3,//level
            28,//Life
            null,//Power
            null,//Durability
            null,//Speed
            LorraineCruxKnight_2)); //Image

        cardList.Add(new Card(
            40, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "ASSASSIN" }, //Classes
            new List<string> { "ASSASSIN", "HUMAN" }, //SubTypes
            "NORM", //Element
            "Tristan, Hired Blade", //Name
            "Tristan Lineage\r\n\r\n" +
            "On Enter: If Tristan has two or more preparation counters on her, draw a card. " +
            "Then if Tristan has four or more preparation counters on her, draw an additional card.", //Effect
            false,//Generated
            2,//CostMemory
            null,//CostReserve
            2,//level
            22,//Life
            null,//Power
            null,//Durability
            null,//Speed
            TristanHiredBlade_0)); //Image

        cardList.Add(new Card(
            41, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "ASSASSIN" }, //Classes
            new List<string> { "ASSASSIN", "HUMAN" }, //SubTypes
            "NORM", //Element
            "Tristan, Hired Blade", //Name
            "Tristan Lineage\r\n\r\n" +
            "On Enter: If Tristan has two or more preparation counters on her, draw a card. " +
            "Then if Tristan has four or more preparation counters on her, draw an additional card.", //Effect
            false,//Generated
            2,//CostMemory
            null,//CostReserve
            2,//level
            22,//Life
            null,//Power
            null,//Durability
            null,//Speed
            TristanHiredBlade_1)); //Image

        cardList.Add(new Card(
            42, //id
            new List<string> { "REGALIA", "ITEM" }, //Types
            new List<string> { "CLERIC" }, //Classes
            new List<string> { "CLERIC", "ACCESSORY" }, //SubTypes
            "NORM", //Element
            "Azure Protective Trinket", //Name
            "Banish Azure Protective Trinket: Banish up to three target fire element cards from a single graveyard.", //Effect
            false,//Generated
            0,//CostMemory
            null,//CostReserve
            null,//level
            null,//Life
            null,//Power
            null,//Durability
            null,//Speed
            AzureProtectiveTrinket)); //Image

        cardList.Add(new Card(
            43, //id
            new List<string> { "REGALIA", "ITEM" }, //Types
            new List<string> { "ASSASSIN" }, //Classes
            new List<string> { "ASSASSIN", "ACCESSORY" }, //SubTypes
            "NORM", //Element
            "Assassin's Mantle", //Name
            "If your champion would take damage, you may banish Assassin's Mantle. " +
            "If you do, prevent 1 of that damage. Put a preparation counter on your champion if damage was prevented this way.", //Effect
            false,//Generated
            0,//CostMemory
            null,//CostReserve
            null,//level
            null,//Life
            null,//Power
            null,//Durability
            null,//Speed
            AssassinsMantle)); //Image

        cardList.Add(new Card(
            44, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "ASSASSIN" }, //Classes
            new List<string> { "ASSASSIN", "HUMAN" }, //SubTypes
            "NORM", //Element
            "Zander, Deft Executor", //Name
            "Zander Lineage\r\n\r\n" +
            "On Enter: Put two preparation counters on Zander. " +
            "Then you may remove a preparation counter from him. " +
            "If you do, return an Assassin action or an Assassin attack card from your graveyard to your hand.", //Effect
            false,//Generated
            2,//CostMemory
            null,//CostReserve
            2,//level
            22,//Life
            null,//Power
            null,//Durability
            null,//Speed
            ZanderDeftExecutor_0)); //Image

        cardList.Add(new Card(
            45, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "ASSASSIN" }, //Classes
            new List<string> { "ASSASSIN", "HUMAN" }, //SubTypes
            "NORM", //Element
            "Zander, Deft Executor", //Name
            "Zander Lineage\r\n\r\n" +
            "On Enter: Put two preparation counters on Zander. " +
            "Then you may remove a preparation counter from him. " +
            "If you do, return an Assassin action or an Assassin attack card from your graveyard to your hand.", //Effect
            false,//Generated
            2,//CostMemory
            null,//CostReserve
            2,//level
            22,//Life
            null,//Power
            null,//Durability
            null,//Speed
            ZanderDeftExecutor_1)); //Image

        cardList.Add(new Card(
            46, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "CLERIC" }, //Classes
            new List<string> { "CLERIC", "HUMAN" }, //SubTypes
            "ASTRA", //Element
            "Arisanna, Astral Zenith", //Name
            "Arisanna Lineage\r\n\r\n" +
            "Once per turn, you may pay (0) rather than pay a card's starcalling costs.", //Effect
            false,//Generated
            3,//CostMemory
            null,//CostReserve
            3,//level
            25,//Life
            null,//Power
            null,//Durability
            null,//Speed
            ArisannaAstralZenith_0)); //Image

        cardList.Add(new Card(
            47, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "CLERIC" }, //Classes
            new List<string> { "CLERIC", "HUMAN" }, //SubTypes
            "ASTRA", //Element
            "Arisanna, Astral Zenith", //Name
            "Arisanna Lineage\r\n\r\n" +
            "Once per turn, you may pay (0) rather than pay a card's starcalling costs.", //Effect
            false,//Generated
            3,//CostMemory
            null,//CostReserve
            3,//level
            25,//Life
            null,//Power
            null,//Durability
            null,//Speed
            ArisannaAstralZenith_1)); //Image

        cardList.Add(new Card(
            48, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "WARRIOR" }, //Classes
            new List<string> { "WARRIOR", "HUMAN" }, //SubTypes
            "CRUX", //Element
            "Lorraine, Spirit Ruler", //Name
            "Lorraine Lineage\r\n\r\n" +
            "On Enter: Choose a Sword regalia card with memory cost 1 or less from your banishment and put it onto the field. " +
            "It enters the field with three additional durability counters on it.", //Effect
            false,//Generated
            3,//CostMemory
            null,//CostReserve
            3,//level
            28,//Life
            null,//Power
            null,//Durability
            null,//Speed
            LorraineSpiritRuler_0)); //Image

        cardList.Add(new Card(
            49, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "WARRIOR" }, //Classes
            new List<string> { "WARRIOR", "HUMAN" }, //SubTypes
            "CRUX", //Element
            "Lorraine, Spirit Ruler", //Name
            "Lorraine Lineage\r\n\r\n" +
            "On Enter: Choose a Sword regalia card with memory cost 1 or less from your banishment and put it onto the field. " +
            "It enters the field with three additional durability counters on it.", //Effect
            false,//Generated
            3,//CostMemory
            null,//CostReserve
            3,//level
            28,//Life
            null,//Power
            null,//Durability
            null,//Speed
            LorraineSpiritRuler_1)); //Image

        cardList.Add(new Card(
            50, //id
            new List<string> { "REGALIA", "ITEM" }, //Types
            new List<string> { "CLERIC" }, //Classes
            new List<string> { "CLERIC", "ACCESSORY" }, //SubTypes
            "NORM", //Element
            "Crimson Protective Trinket", //Name
            "Banish Crimson Protective Trinket: " +
            "Target opponent reveals two cards at random from their memory. " +
            "Banish each wind element card revealed this way.", //Effect
            false,//Generated
            1,//CostMemory
            null,//CostReserve
            null,//level
            null,//Life
            null,//Power
            null,//Durability
            null,//Speed
            CrimsonProtectiveTrinket)); //Image

        cardList.Add(new Card(
            51, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "ASSASSIN" }, //Classes
            new List<string> { "ASSASSIN", "HUMAN" }, //SubTypes
            "UMBRA", //Element
            "Tristan, Shadowreaver", //Name
            "Tristan Lineage\r\n\r\n" +
            "Tristan can level up into champions of the same base level. " +
            "When she does, draw two cards.\r\n\r\n" +
            "On Enter: Banish the top four cards of target opponent’s deck face down. " +
            "As long as they’re banished, you may play those cards, ignoring their elemental requirements.", //Effect
            false,//Generated
            3,//CostMemory
            null,//CostReserve
            3,//level
            25,//Life
            null,//Power
            null,//Durability
            null,//Speed
            TristanShadowreaver_0)); //Image

        cardList.Add(new Card(
            52, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "ASSASSIN" }, //Classes
            new List<string> { "ASSASSIN", "HUMAN" }, //SubTypes
            "UMBRA", //Element
            "Tristan, Shadowreaver", //Name
            "Tristan Lineage\r\n\r\n" +
            "Tristan can level up into champions of the same base level. " +
            "When she does, draw two cards.\r\n\r\n" +
            "On Enter: Banish the top four cards of target opponent’s deck face down. " +
            "As long as they’re banished, you may play those cards, ignoring their elemental requirements.", //Effect
            false,//Generated
            3,//CostMemory
            null,//CostReserve
            3,//level
            25,//Life
            null,//Power
            null,//Durability
            null,//Speed
            TristanShadowreaver_1)); //Image

        cardList.Add(new Card(
            53, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "CLERIC" }, //Classes
            new List<string> { "CLERIC", "HUMAN" }, //SubTypes
            "ASTRA", //Element
            "Arisanna, Lucent Arbiter", //Name
            "Arisanna Lineage \r\n\r\n" +
            "(3),REST : Reveal the top card of your deck. " +
            "Negate target card activation if its reserve cost is equal to the reserve cost of the revealed card.", //Effect
            false,//Generated
            3,//CostMemory
            null,//CostReserve
            3,//level
            25,//Life
            null,//Power
            null,//Durability
            null,//Speed
            ArisannaLucentArbiter_0)); //Image

        cardList.Add(new Card(
            54, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "CLERIC" }, //Classes
            new List<string> { "CLERIC", "HUMAN" }, //SubTypes
            "ASTRA", //Element
            "Arisanna, Lucent Arbiter", //Name
            "Arisanna Lineage \r\n\r\n" +
            "(3),REST : Reveal the top card of your deck. " +
            "Negate target card activation if its reserve cost is equal to the reserve cost of the revealed card.", //Effect
            false,//Generated
            3,//CostMemory
            null,//CostReserve
            3,//level
            25,//Life
            null,//Power
            null,//Durability
            null,//Speed
            ArisannaLucentArbiter_1)); //Image

        cardList.Add(new Card(
            55, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "MAGE" }, //Classes
            new List<string> { "MAGE", "HUMAN" }, //SubTypes
            "NORM", //Element
            "Rai, Spellcrafter", //Name
            "On Enter: " +
            "Put two enlighten counters on Rai. " +
            "(You may remove three enlighten counters from your champion to draw a card.)", //Effect
            false,//Generated
            1,//CostMemory
            null,//CostReserve
            1,//level
            19,//Life
            null,//Power
            null,//Durability
            null,//Speed
            RaiSpellcrafter_0)); //Image

        cardList.Add(new Card(
            56, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "MAGE" }, //Classes
            new List<string> { "MAGE", "HUMAN" }, //SubTypes
            "NORM", //Element
            "Rai, Spellcrafter", //Name
            "On Enter: " +
            "Put two enlighten counters on Rai. " +
            "(You may remove three enlighten counters from your champion to draw a card.)", //Effect
            false,//Generated
            1,//CostMemory
            null,//CostReserve
            1,//level
            19,//Life
            null,//Power
            null,//Durability
            null,//Speed
            RaiSpellcrafter_1)); //Image

        cardList.Add(new Card(
            57, //id
            new List<string> { "REGALIA", "ITEM" }, //Types
            new List<string> { "CLERIC" }, //Classes
            new List<string> { "CLERIC", "SOLVENT" }, //SubTypes
            "NORM", //Element
            "Alkahestt", //Name
            "At the beginning of your recollection phase, put an age counter on a Potion item you control." +
            "\r\n\r\nLevel 4+ Banish Alkahest: " +
            "Destroy target item or weapon with memory cost 0 or reserve cost 4 or less.", //Effect
            false,//Generated
            0,//CostMemory
            null,//CostReserve
            null,//level
            null,//Life
            null,//Power
            null,//Durability
            null,//Speed
            Alkahest)); //Image

        cardList.Add(new Card(
            58, //id
            new List<string> { "REGALIA", "ITEM" }, //Types
            new List<string> { "CLERIC" }, //Classes
            new List<string> { "CLERIC", "ARTIFACT" }, //SubTypes
            "NORM", //Element
            "Quicksilver Grail", //Name
            "Divine Relic (You can only have one card with this keyword in your material deck.)" +
            "\r\n\r\nOn Enter: " +
            "Banish a non-champion card from your material deck face down.\r\n\r\n" +
            "Banish Quicksilver Grail: You may play the banished card. " +
            "(You still pay for its costs.)", //Effect
            false,//Generated
            0,//CostMemory
            null,//CostReserve
            null,//level
            null,//Life
            null,//Power
            null,//Durability
            null,//Speed
            QuicksilverGrail)); //Image

        cardList.Add(new Card(
            59, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "RANGER" }, //Classes
            new List<string> { "RANGER", "HUMAN" }, //SubTypes
            "NORM", //Element
            "Diana, Keen Huntress", //Name
            "Lineage Release — Materialize a Gun card from your material deck. " +
            "(Activate this ability by banishing this card from your champion's inner lineage.)", //Effect
            false,//Generated
            1,//CostMemory
            null,//CostReserve
            1,//level
            19,//Life
            null,//Power
            null,//Durability
            null,//Speed
            DianaKeenHuntress_0)); //Image

        cardList.Add(new Card(
            60, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "RANGER" }, //Classes
            new List<string> { "RANGER", "HUMAN" }, //SubTypes
            "NORM", //Element
            "Diana, Keen Huntress", //Name
            "Lineage Release — Materialize a Gun card from your material deck. " +
            "(Activate this ability by banishing this card from your champion's inner lineage.)", //Effect
            false,//Generated
            1,//CostMemory
            null,//CostReserve
            1,//level
            19,//Life
            null,//Power
            null,//Durability
            null,//Speed
            DianaKeenHuntress_1)); //Image

        cardList.Add(new Card(
            61, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "MAGE" }, //Classes
            new List<string> { "MAGE", "HUMAN" }, //SubTypes
            "NORM", //Element
            "Rai, Archmage", //Name
            "Rai Lineage (Rai, Archmage must be leveled from a previous level \"Rai\" champion.)" +
            "\r\n\r\nInherited Effect: " +
            "Whenever you activate your first Mage action card each turn, put an enlighten counter on your champion. " +
            "(Your champion has this ability as long as this card is part of its lineage.)", //Effect
            false,//Generated
            2,//CostMemory
            null,//CostReserve
            2,//level
            22,//Life
            null,//Power
            null,//Durability
            null,//Speed
            RaiArchmage_0)); //Image

        cardList.Add(new Card(
            62, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "MAGE" }, //Classes
            new List<string> { "MAGE", "HUMAN" }, //SubTypes
            "NORM", //Element
            "Rai, Archmage", //Name
            "Rai Lineage (Rai, Archmage must be leveled from a previous level \"Rai\" champion.)" +
            "\r\n\r\nInherited Effect: " +
            "Whenever you activate your first Mage action card each turn, put an enlighten counter on your champion. " +
            "(Your champion has this ability as long as this card is part of its lineage.)", //Effect
            false,//Generated
            2,//CostMemory
            null,//CostReserve
            2,//level
            22,//Life
            null,//Power
            null,//Durability
            null,//Speed
            RaiArchmage_1)); //Image

        cardList.Add(new Card(
            63, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "MAGE" }, //Classes
            new List<string> { "MAGE", "HUMAN" }, //SubTypes
            "ARCANE", //Element
            "Rai, Storm Seer", //Name
            "Rai Lineage\r\n\r\n" +
            "Rai gets +1 level for each arcane element Mage Spell card in your banishment.", //Effect
            false,//Generated
            3,//CostMemory
            null,//CostReserve
            3,//level
            25,//Life
            null,//Power
            null,//Durability
            null,//Speed
            RaiStormSeer_0)); //Image

        cardList.Add(new Card(
            64, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "MAGE" }, //Classes
            new List<string> { "MAGE", "HUMAN" }, //SubTypes
            "ARCANE", //Element
            "Rai, Storm Seer", //Name
            "Rai Lineage\r\n\r\n" +
            "Rai gets +1 level for each arcane element Mage Spell card in your banishment.", //Effect
            false,//Generated
            3,//CostMemory
            null,//CostReserve
            3,//level
            25,//Life
            null,//Power
            null,//Durability
            null,//Speed
            RaiStormSeer_1)); //Image

        cardList.Add(new Card(
            65, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "MAGE" }, //Classes
            new List<string> { "MAGE", "HUMAN" }, //SubTypes
            "ARCANE", //Element
            "Rai, Storm Seer", //Name
            "Rai Lineage\r\n\r\n" +
            "Rai gets +1 level for each arcane element Mage Spell card in your banishment.", //Effect
            false,//Generated
            3,//CostMemory
            null,//CostReserve
            3,//level
            25,//Life
            null,//Power
            null,//Durability
            null,//Speed
            RaiStormSeer_2)); //Image

        cardList.Add(new Card(
            66, //id
            new List<string> { "REGALIA", "ITEM" },//Types
            new List<string> { "GUARDIAN" }, //Classes
            new List<string> { "GUARDIAN", "ACCESSORY" }, //SubTypes
            "NORM",//Element
            "Tariff Ring",//Name
            "Banish Tariff Ring: " +
            "Until end of turn, players can't declare attacks unless they pay (2)" +
            "for each attack declaration. Activate this ability only during an opponent's recollection phase.",//Effect
            false,//Generated
            0,//CostMemory
            null,//CostReserve
            null,//level
            null,//Life
            null,//Power
            null,//Durability
            null,//Speed
            TariffRing));//Image

        cardList.Add(new Card(
            67, //id
            new List<string> { "REGALIA", "ITEM" },//Types
            new List<string> { "CLERIC" }, //Classes
            new List<string> { "CLERIC", "ACCESSORY" }, //SubTypes
            "NORM",//Element
            "Backup Charger",//Name
            "(3), Banish Backup Charger: Summon a Powercell token rested. Draw a card into your memory.",//Effect
            false,//Generated
            0,//CostMemory
            null,//CostReserve
            null,//level
            null,//Life
            null,//Power
            null,//Durability
            null,//Speed
            BackupCharger));//Image

        cardList.Add(new Card(
            68, //id
            new List<string> { "REGALIA", "ITEM" },//Types
            new List<string> { "TAMER" }, //Classes
            new List<string> { "TAMER", "FOOD" }, //SubTypes
            "NORM",//Element
            "Key Slime Pudding",//Name
            "Banish Key Slime Pudding: " +
            "Until end of turn, Slime allies that enter the field under your control enter with an additional buff counter on them.",//Effect
            false,//Generated
            0,//CostMemory
            null,//CostReserve
            null,//level
            null,//Life
            null,//Power
            null,//Durability
            null,//Speed
            KeySlimePudding));//Image

        cardList.Add(new Card(
            69, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "RANGER" }, //Classes
            new List<string> { "RANGER", "HUMAN" }, //SubTypes
            "NORM", //Element
            "Diana, Deadly Duelist", //Name
            "Diana Lineage\r\n\r\n" +
            "On Enter: Materialize a Bullet card from your material deck." +
            "\r\n\r\nInherited Effect: Ranged 2", //Effect
            false,//Generated
            2,//CostMemory
            null,//CostReserve
            2,//level
            22,//Life
            null,//Power
            null,//Durability
            null,//Speed
            DianaDeadlyDuelist_0)); //Image

        cardList.Add(new Card(
            70, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "RANGER" }, //Classes
            new List<string> { "RANGER", "HUMAN" }, //SubTypes
            "NORM", //Element
            "Diana, Deadly Duelist", //Name
            "Diana Lineage\r\n\r\n" +
            "On Enter: Materialize a Bullet card from your material deck." +
            "\r\n\r\nInherited Effect: Ranged 2", //Effect
            false,//Generated
            2,//CostMemory
            null,//CostReserve
            2,//level
            22,//Life
            null,//Power
            null,//Durability
            null,//Speed
            DianaDeadlyDuelist_1)); //Image

        cardList.Add(new Card(
            71, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "RANGER" }, //Classes
            new List<string> { "RANGER", "HUMAN" }, //SubTypes
            "NORM", //Element
            "Diana, Deadly Duelist", //Name
            "Diana Lineage\r\n\r\n" +
            "On Enter: Materialize a Bullet card from your material deck." +
            "\r\n\r\nInherited Effect: Ranged 2", //Effect
            false,//Generated
            2,//CostMemory
            null,//CostReserve
            2,//level
            22,//Life
            null,//Power
            null,//Durability
            null,//Speed
            DianaDeadlyDuelist_2)); //Image

        cardList.Add(new Card(
            72, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "MAGE" }, //Classes
            new List<string> { "MAGE", "HUMAN" }, //SubTypes
            "ARCANE", //Element
            "Rai, Mana Weaver", //Name
            "Rai Lineage\r\n\r\n" +
            "REST, Remove four enlighten counters from Rai: Copy target Mage Spell card activation. " +
            "You may choose new targets for the copy.", //Effect
            false,//Generated
            3,//CostMemory
            null,//CostReserve
            3,//level
            25,//Life
            null,//Power
            null,//Durability
            null,//Speed
            RaiManaWeaver_0)); //Image

        cardList.Add(new Card(
            73, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "MAGE" }, //Classes
            new List<string> { "MAGE", "HUMAN" }, //SubTypes
            "ARCANE", //Element
            "Rai, Mana Weaver", //Name
            "Rai Lineage\r\n\r\n" +
            "REST, Remove four enlighten counters from Rai: Copy target Mage Spell card activation. " +
            "You may choose new targets for the copy.", //Effect
            false,//Generated
            3,//CostMemory
            null,//CostReserve
            3,//level
            25,//Life
            null,//Power
            null,//Durability
            null,//Speed
            RaiManaWeaver_1)); //Image

        cardList.Add(new Card(
            74, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "TAMER" }, //Classes
            new List<string> { "TAMER", "HUMAN" }, //SubTypes
            "TERA", //Element
            "Silvie, Loved by All", //Name
            "Silvie Lineage\r\n\r\n" +
            "Animal and Beast allies you control get +1 LIFE and have intercept.", //Effect
            false,//Generated
            3,//CostMemory
            null,//CostReserve
            3,//level
            25,//Life
            null,//Power
            null,//Durability
            null,//Speed
            SilvieLovedbyAll_0)); //Image

        cardList.Add(new Card(
            75, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "TAMER" }, //Classes
            new List<string> { "TAMER", "HUMAN" }, //SubTypes
            "TERA", //Element
            "Silvie, Loved by All", //Name
            "Silvie Lineage\r\n\r\n" +
            "Animal and Beast allies you control get +1 LIFE and have intercept.", //Effect
            false,//Generated
            3,//CostMemory
            null,//CostReserve
            3,//level
            25,//Life
            null,//Power
            null,//Durability
            null,//Speed
            SilvieLovedbyAll_1)); //Image

        cardList.Add(new Card(
            76, //id
            new List<string> { "REGALIA", "ITEM" },//Types
            new List<string> { "CLERIC" }, //Classes
            new List<string> { "CLERIC", "SCRIPTURE" }, //SubTypes
            "NORM",//Element
            "Tithe Proclamation",//Name
            "On Enter: Draw a card.\r\n\r\n" +
            "Players can't draw more than three cards each turn unless it's their first turn of the game.",//Effect
            false,//Generated
            1,//CostMemory
            null,//CostReserve
            null,//level
            null,//Life
            null,//Power
            null,//Durability
            null,//Speed
            TitheProclamation_0));//Image

        cardList.Add(new Card(
            77, //id
            new List<string> { "REGALIA", "ITEM" },//Types
            new List<string> { "CLERIC" }, //Classes
            new List<string> { "CLERIC", "SCRIPTURE" }, //SubTypes
            "NORM",//Element
            "Tithe Proclamation",//Name
            "On Enter: Draw a card.\r\n\r\n" +
            "Each player can't draw more than three cards each turn unless it's their first turn of the game.",//Effect
            false,//Generated
            1,//CostMemory
            null,//CostReserve
            null,//level
            null,//Life
            null,//Power
            null,//Durability
            null,//Speed
            TitheProclamation_1));//Image

        cardList.Add(new Card(
            78, //id
            new List<string> { "REGALIA", "ITEM" },//Types
            new List<string> { "ASSASSIN" }, //Classes
            new List<string> { "ASSASSIN", "GLOVE" }, //SubTypes
            "WIND",//Element
            "Gearstride Gloves",//Name
            "On Enter: Put a preparation counter on your champion.\r\n\r\n" +
            "(Class Bonus) Level 2+ Banish Gearstride Gloves: " +
            "The next Reaction card you activate this turn costs 1 less to activate.",//Effect
            false,//Generated
            0,//CostMemory
            null,//CostReserve
            null,//level
            null,//Life
            null,//Power
            null,//Durability
            null,//Speed
            GearstrideGloves));//Image

        cardList.Add(new Card(
            79, //id
            new List<string> { "REGALIA", "ITEM" },//Types
            new List<string> { "TAMER" }, //Classes
            new List<string> { "TAMER", "ARTIFACT" }, //SubTypes
            "NORM",//Element
            "Clockwork Musicbox",//Name
            "Hindered (This object enters the field rested.)\r\n\r\n" +
            "(Class Bonus) Whenever you activate a Harmony or Melody card from your hand, " +
            "you may banish it as it resolves.\r\n\r\n: " +
            "REST You may activate a card banished by Clockwork Musicbox. (You still pay its costs.)",//Effect
            false,//Generated
            0,//CostMemory
            null,//CostReserve
            null,//level
            null,//Life
            null,//Power
            null,//Durability
            null,//Speed
            ClockworkMusicbox));//Image

        cardList.Add(new Card(
            80, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "SPIRIT" }, //Classes
            new List<string> { "SPIRIT" }, //SubTypes
            "FIRE", //Element
            "Aithne, Spirit of Fire", //Name
            "On Enter: Draw seven cards.", //Effect
            false,//Generated
            0,//CostMemory
            null,//CostReserve
            0,//level
            15,//Life
            null,//Power
            null,//Durability
            null,//Speed
            AithneSpiritofFire)); //Image

        cardList.Add(new Card(
            81, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "RANGER" }, //Classes
            new List<string> { "RANGER", "HUMAN" }, //SubTypes
            "UMBRA", //Element
            "Diana, Cursebreaker", //Name
            "Diana Lineage\r\n\r\n" +
            "Banish all Curse cards from Diana's lineage: " +
            "Materialize two Bullet cards from your material deck. " +
            "Until end of turn, Diana gains \"On Attack: Wake up Diana.\" " +
            "Activate this ability only if there are four or more Curse cards in Diana's lineage. ", //Effect
            false,//Generated
            3,//CostMemory
            null,//CostReserve
            3,//level
            25,//Life
            null,//Power
            null,//Durability
            null,//Speed
            DianaCursebreaker_0)); //Image

        cardList.Add(new Card(
            82, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "RANGER" }, //Classes
            new List<string> { "RANGER", "HUMAN" }, //SubTypes
            "UMBRA", //Element
            "Diana, Cursebreaker", //Name
            "Diana Lineage\r\n\r\n" +
            "Banish all Curse cards from Diana's lineage: " +
            "Materialize two Bullet cards from your material deck. " +
            "Until end of turn, Diana gains \"On Attack: Wake up Diana.\" " +
            "Activate this ability only if there are four or more Curse cards in Diana's lineage. ", //Effect
            false,//Generated
            3,//CostMemory
            null,//CostReserve
            3,//level
            25,//Life
            null,//Power
            null,//Durability
            null,//Speed
            DianaCursebreaker_1)); //Image

        cardList.Add(new Card(
            83, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "TAMER" }, //Classes
            new List<string> { "TAMER", "HUMAN" }, //SubTypes
            "NORM", //Element
            "Silvie, Wilds Whisperer", //Name
            "On Enter: " +
            "The next Animal or Beast ally card you activate this turn enters the field with an additional buff counter on it. " +
            "(Allies get +1 power and +1 life for each buff counter on them.)", //Effect
            false,//Generated
            1,//CostMemory
            null,//CostReserve
            1,//level
            19,//Life
            null,//Power
            null,//Durability
            null,//Speed
            SilvieWildsWhisperer_0)); //Image

        cardList.Add(new Card(
            84, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "TAMER" }, //Classes
            new List<string> { "TAMER", "HUMAN" }, //SubTypes
            "NORM", //Element
            "Silvie, Wilds Whisperer", //Name
            "On Enter: " +
            "The next Animal or Beast ally card you activate this turn enters the field with an additional buff counter on it. " +
            "(Allies get +1 power and +1 life for each buff counter on them.)", //Effect
            false,//Generated
            1,//CostMemory
            null,//CostReserve
            1,//level
            19,//Life
            null,//Power
            null,//Durability
            null,//Speed
            SilvieWildsWhisperer_1)); //Image

        cardList.Add(new Card(
            85, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "ASSASSIN" }, //Classes
            new List<string> { "ASSASSIN", "HUMAN" }, //SubTypes
            "LUXEM", //Element
            "Zander, Blinding Steel", //Name
            "Zander Lineage\r\n\r\n" +
            "At the beginning of your recollection phase, you may reveal all cards in your memory. " +
            "For each luxem element card revealed, each opponent puts a card from their hand into their memory.", //Effect
            false,//Generated
            3,//CostMemory
            null,//CostReserve
            3,//level
            25,//Life
            null,//Power
            null,//Durability
            null,//Speed
            ZanderBlindingSteel_0)); //Image

        cardList.Add(new Card(
            86, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "ASSASSIN" }, //Classes
            new List<string> { "ASSASSIN", "HUMAN" }, //SubTypes
            "LUXEM", //Element
            "Zander, Blinding Steel", //Name
            "Zander Lineage\r\n\r\n" +
            "At the beginning of your recollection phase, you may reveal all cards in your memory. " +
            "For each luxem element card revealed, each opponent puts a card from their hand into their memory.", //Effect
            false,//Generated
            3,//CostMemory
            null,//CostReserve
            3,//level
            25,//Life
            null,//Power
            null,//Durability
            null,//Speed
            ZanderBlindingSteel_1)); //Image

        cardList.Add(new Card(
            87, //id
            new List<string> { "REGALIA", "ITEM" }, //Types
            new List<string> { "CLERIC" }, //Classes
            new List<string> { "CLERIC", "ACCESSORY" }, //SubTypes
            "NORM", //Element
            "Viridian Protective Trinket", //Name
            "Banish Viridian Protective Trinket:" +
            "During your turn, water element cards your opponents activate cost 2 more to activat", //Effect
            false,//Generated
            0,//CostMemory
            null,//CostReserve
            null,//level
            null,//Life
            null,//Power
            null,//Durability
            null,//Speed
            ViridianProtectiveTrinket_0)); //Image

        cardList.Add(new Card(
            88, //id
            new List<string> { "REGALIA", "ITEM" }, //Types
            new List<string> { "CLERIC" }, //Classes
            new List<string> { "CLERIC", "ACCESSORY" }, //SubTypes
            "NORM", //Element
            "Viridian Protective Trinket", //Name
            "During your turn, water element cards your opponents activate cost 2 more to activat", //Effect
            false,//Generated
            0,//CostMemory
            null,//CostReserve
            null,//level
            null,//Life
            null,//Power
            null,//Durability
            null,//Speed
            ViridianProtectiveTrinket_1)); //Image

        cardList.Add(new Card(
            89, //id
            new List<string> { "REGALIA", "WEAPON" }, //Types
            new List<string> { "RANGER" }, //Classes
            new List<string> { "RANGER", "GUN" }, //SubTypes
            "NORM", //Element
            "Framework Sidearm", //Name
            "(Gun — Must be loaded to use for an attack and can’t be used with an attack card.)" +
            "\r\n\r\n(Class Bonus) You may pay (3) to activate this card from your material deck.", //Effect
            false,//Generated
            0,//CostMemory
            null,//CostReserve
            null,//level
            null,//Life
            1,//Power
            1,//Durability
            null,//Speed
            FrameworkSidearm)); //Image

        cardList.Add(new Card(
            90, //id
            new List<string> { "REGALIA", "ITEM" }, //Types
            new List<string> { "TAMER" }, //Classes
            new List<string> { "TAMER", "COMPONENT" }, //SubTypes
            "NORM", //Element
            "Slime Nexus", //Name
            "Banish Slime Nexus: " +
            "The next Slime ally card you activate this turn costs 3 less to activate.", //Effect
            false,//Generated
            1,//CostMemory
            null,//CostReserve
            null,//level
            null,//Life
            null,//Power
            null,//Durability
            null,//Speed
            SlimeNexus)); //Image

        cardList.Add(new Card(
            91, //id
            new List<string> { "REGALIA", "ITEM" },//Types
            new List<string> { "ASSASSIN", "CLERIC" }, //Classes
            new List<string> { "ASSASSIN", "CLERIC", "BAUBLE" }, //SubTypes
            "UMBRA",//Element
            "Dusksoul Stone",//Name
            "As an additional cost to materialize this card, " +
            "banish two ally cards from a single graveyard.\r\n\r\n" +
            "Phantasias you control have spellshroud. " +
            "(Objects with spellshroud can't be targeted by Spells.)\r\n\r\n" +
            "Banish Dusksoul Stone: " +
            "Banish up to two cards from a single graveyard.",//Effect
            false,//Generated
            0,//CostMemory
            null,//CostReserve
            null,//level
            null,//Life
            null,//Power
            null,//Durability
            null,//Speed
            DusksoulStone));//Image

        cardList.Add(new Card(
            92, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "SPIRIT" }, //Classes
            new List<string> { "SPIRIT" }, //SubTypes
            "NORM", //Element
            "Morrigan, Lost Spirit", //Name
            "On Enter: Draw seven cards.", //Effect
            false,//Generated
            0,//CostMemory
            null,//CostReserve
            0,//level
            15,//Life
            null,//Power
            null,//Durability
            null,//Speed
            MorriganLostSpirit)); //Image

        cardList.Add(new Card(
            93, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "RANGER" }, //Classes
            new List<string> { "RANGER", "HUMAN" }, //SubTypes
            "UMBRA", //Element
            "Diana, Duskstalker", //Name
            "Diana Lineage\r\n\r\n" +
            "On Enter: Diana becomes distant. \r\n\r\n" +
            "On Champion Hit: " +
            "Generate a Creeping Torment card and put it on the bottom of the hit champion's lineage. " +
            "(To generate, add that card from outside of the game.) ", //Effect
            false,//Generated
            3,//CostMemory
            null,//CostReserve
            3,//level
            25,//Life
            null,//Power
            null,//Durability
            null,//Speed
            DianaDuskstalker_0)); //Image

        cardList.Add(new Card(
            94, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "RANGER" }, //Classes
            new List<string> { "RANGER", "HUMAN" }, //SubTypes
            "UMBRA", //Element
            "Diana, Duskstalker", //Name
            "Diana Lineage\r\n\r\n" +
            "On Enter: Diana becomes distant. \r\n\r\n" +
            "On Champion Hit: " +
            "Generate a Creeping Torment card and put it on the bottom of the hit champion's lineage. " +
            "(To generate, add that card from outside of the game.) ", //Effect
            false,//Generated
            3,//CostMemory
            null,//CostReserve
            3,//level
            25,//Life
            null,//Power
            null,//Durability
            null,//Speed
            DianaDuskstalker_1)); //Image

        cardList.Add(new Card(
            95,//id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "TAMER" }, //Classes
            new List<string> { "TAMER", "HUMAN" }, //SubTypes
            "NORM", //Element
            "Silvie, With the Pack", //Name
            "Silvie Lineage\r\n\r\n" +
            "On Enter: " +
            "If you control an Animal ally, draw a card. " +
            "If you control a Beast ally, draw a card.", //Effect
            false,//Generated
            2,//CostMemory
            null,//CostReserve
            2,//level
            22,//Life
            null,//Power
            null,//Durability
            null,//Speed
            SilvieWiththePack_0)); //Image

        cardList.Add(new Card(
            96,//id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "TAMER" }, //Classes
            new List<string> { "TAMER", "HUMAN" }, //SubTypes
            "NORM", //Element
            "Silvie, With the Pack", //Name
            "Silvie Lineage\r\n\r\n" +
            "On Enter: " +
            "If you control an Animal ally, draw a card. " +
            "If you control a Beast ally, draw a card.", //Effect
            false,//Generated
            2,//CostMemory
            null,//CostReserve
            2,//level
            22,//Life
            null,//Power
            null,//Durability
            null,//Speed
            SilvieWiththePack_1)); //Image

        cardList.Add(new Card(
            97,//id
            new List<string> { "REGALIA", "ITEM" },//Types
            new List<string> { "TAMER" }, //Classes
            new List<string> { "TAMER", "ACCESSORY" }, //SubTypes
            "FIRE",//Element
            "Beastsoul Visage",//Name
            "Ally Link" +
            "This object enters the field linked to target ally. " +
            "If the link is broken, sacrifice this object.)" +
            "\r\n\r\nLinked ally gets +2, POWER has pride 3, and is a Beast in addition to its other types.",//Effect
            false,//Generated
            0,//CostMemory
            null,//CostReserve
            null,//level
            null,//Life
            null,//Power
            null,//Durability
            null,//Speed
            BeastsoulVisage));//Image

        cardList.Add(new Card(
            98, //id
            new List<string> { "REGALIA", "WEAPON" }, //Types
            new List<string> { "ASSASSIN" }, //Classes
            new List<string> { "ASSASSIN", "DAGGER" }, //SubTypes
            "NORM", //Element
            "Mercenary's Blade", //Name
            "(Class Bonus) " +
            "You may remove a preparation counter from your champion to activate this card from your material deck. " +
            "(Apply this effect only if your champion’s class matches this card’s class.)", //Effect
            false,//Generated
            0,//CostMemory
            null,//CostReserve
            null,//level
            null,//Life
            1,//Power
            1,//Durability
            null,//Speed
            MercenarysBlade)); //Image

        cardList.Add(new Card(
            99, //id
            new List<string> { "REGALIA", "WEAPON" }, //Types
            new List<string> { "ASSASSIN" }, //Classes
            new List<string> { "ASSASSIN", "DAGGER" }, //SubTypes
            "UMBRA", //Element
            "Malignant Athame", //Name
            "(Class Bonus) " +
            "On Champion Hit: " +
            "You may have that opponent swap the cards in their hand and memory. " +
            "Then if there are four or more cards in their memory, deal 2 unpreventable damage to the hit champion.", //Effect
            false,//Generated
            0,//CostMemory
            null,//CostReserve
            null,//level
            null,//Life
            1,//Power
            2,//Durability
            null,//Speed
            MalignantAthame)); //Image

        cardList.Add(new Card(
            100, //id
            new List<string> { "REGALIA", "ITEM" },//Types
            new List<string> { "TAMER" }, //Classes
            new List<string> { "TAMER", "ARTIFACT" }, //SubTypes
            "TERA",//Element
            "Slime Totem",//Name
            "Slime allies you control have vigor. (These units wake up at the beginning of your end phase.)",//Effect
            false,//Generated
            0,//CostMemory
            null,//CostReserve
            null,//level
            null,//Life
            null,//Power
            null,//Durability
            null,//Speed
            SlimeTotem));//Image

        cardList.Add(new Card(
            101, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "SPIRIT" }, //Classes
            new List<string> { "SPIRIT" }, //SubTypes
            "NORM", //Element
            "Prismatic Spirit", //Name
            "On Enter: " +
            "Draw six cards then choose two basic elements. " +
            "Prismatic Spirit gains \"Inherited Effect: This object is each of the chosen elements in addition to its other elements.\"", //Effect
            false,//Generated
            0,//CostMemory
            null,//CostReserve
            0,//level
            15,//Life
            null,//Power
            null,//Durability
            null,//Speed
            PrismaticSpirit)); //Image

        cardList.Add(new Card(
            102, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "GUARDIAN" }, //Classes
            new List<string> { "GUARDIAN", "HUMAN" }, //SubTypes
            "NORM", //Element
            "Tonoris, Lone Mercenary", //Name
            "On Enter: " +
            "Tonoris gains taunt until the beginning of your next turn. " +
            "(While awake, this unit must be targeted before other units you control during your opponents' attack declarations if able.)", //Effect
            false,//Generated
            1,//CostMemory
            null,//CostReserve
            1,//level
            20,//Life
            null,//Power
            null,//Durability
            null,//Speed
            TonorisLoneMercenary_0)); //Image

        cardList.Add(new Card(
            103, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "GUARDIAN" }, //Classes
            new List<string> { "GUARDIAN", "HUMAN" }, //SubTypes
            "NORM", //Element
            "Tonoris, Lone Mercenary", //Name
            "On Enter: " +
            "Tonoris gains taunt until the beginning of your next turn. " +
            "(While awake, this unit must be targeted before other units you control during your opponents' attack declarations if able.)", //Effect
            false,//Generated
            1,//CostMemory
            null,//CostReserve
            1,//level
            20,//Life
            null,//Power
            null,//Durability
            null,//Speed
            TonorisLoneMercenary_1)); //Image

        cardList.Add(new Card(
            104, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "TAMER" }, //Classes
            new List<string> { "TAMER", "HUMAN" }, //SubTypes
            "TERA", //Element
            "Silvie, Earth's Tune", //Name
            "Silvie Lineage\r\n\r\n" +
            "On Enter: " +
            "Reveal cards from the top of your deck until you reveal a tera element Animal or Beast ally card. " +
            "Put that card into your hand and the rest on the bottom of your deck in a random order.", //Effect
            false,//Generated
            3,//CostMemory
            null,//CostReserve
            3,//level
            25,//Life
            null,//Power
            null,//Durability
            null,//Speed
            SilvieEarthTune_0)); //Image

        cardList.Add(new Card(
            105, //id
            new List<string> { "CHAMPION" }, //Types
            new List<string> { "TAMER" }, //Classes
            new List<string> { "TAMER", "HUMAN" }, //SubTypes
            "TERA", //Element
            "Silvie, Earth's Tune", //Name
            "Silvie Lineage\r\n\r\n" +
            "On Enter: " +
            "Reveal cards from the top of your deck until you reveal a tera element Animal or Beast ally card. " +
            "Put that card into your hand and the rest on the bottom of your deck in a random order.", //Effect
            false,//Generated
            3,//CostMemory
            null,//CostReserve
            3,//level
            25,//Life
            null,//Power
            null,//Durability
            null,//Speed
            SilvieEarthTune_1)); //Image

        cardList.Add(new Card(
            106, //id
            new List<string> { "REGALIA", "WEAPON" }, //Types
            new List<string> { "WARRIOR" }, //Classes
            new List<string> { "WARRIOR", "SWORD" }, //SubTypes
            "NORM", //Element
            "Clarent, Sword of Peace", //Name
            "(Class Bonus) " +
            "Remove a durability counter from Clarent: " +
            "Prevent the next 1 non-combat damage that would be dealt to each unit you control this turn. " +
            "(Activate this ability only if your champion's class matches this card's class.)", //Effect
            false,//Generated
            1,//CostMemory
            null,//CostReserve
            null,//level
            null,//Life
            1,//Power
            2,//Durability
            null,//Speed
            ClarentSwordofPeace)); //Image

        cardList.Add(new Card(
            107, //id
            new List<string> { "REGALIA", "ITEM" }, //Types
            new List<string> { "MAGE" }, //Classes
            new List<string> { "MAGE", "ARTIFACT" }, //SubTypes
            "FIRE", //Element
            "Explosive Rune", //Name
            "Banish Explosive Rune: " +
            "Deal 1 damage to target ally. Class Bonus: If that ally is attacking, deal 2 damage to it instead.", //Effect
            false,//Generated
            0,//CostMemory
            null,//CostReserve
            null,//level
            null,//Life
            null,//Power
            null,//Durability
            null,//Speed
            ExplosiveRune)); //Image

        cardList.Add(new Card(
            108, //id
            new List<string> { "REGALIA", "ITEM" }, //Types
            new List<string> { "ASSASSIN" }, //Classes
            new List<string> { "ASSASSIN", "ACCESSORY" }, //SubTypes
            "UMBRA", //Element
            "Shadeblood Coating", //Name
            "Banish Shadeblood Coating: " +
            "Up to three target units you control gain " +
            "\"On Hit: Put a preparation counter on your champion\" until end of turn.", //Effect
            false,//Generated
            0,//CostMemory
            null,//CostReserve
            null,//level
            null,//Life
            null,//Power
            null,//Durability
            null,//Speed
            ShadebloodCoating)); //Image

        cardList.Add(new Card(
            109, //id
            new List<string> { "REGALIA", "ITEM" }, //Types
            new List<string> { "TAMER", "MAGE" }, //Classes
            new List<string> { "TAMER", "MAGE", "SCEPTER" }, //SubTypes
            "TERA", //Element
            "Verdant Scepter", //Name
            "(Class Bonus)" +
            "On Enter: " +
            "You may banish a Slime ally you control. " +
            "If you do, put an amount of refinement counters on Verdant Scepter equal to the banished ally's power plus 1." +
            "\r\n\r\nREST, Remove a refinement counter from Verdant Scepter: " +
            "Put a buff counter on each of up to two Slime allies you control then draw a card.", //Effect
            false,//Generated
            1,//CostMemory
            null,//CostReserve
            null,//level
            null,//Life
            null,//Power
            null,//Durability
            null,//Speed
            VerdantScepter)); //Image

        cardList.Add(new Card(
            110, //id
            new List<string> { "REGALIA", "ITEM" },//Types
            new List<string> { "CLERIC", "GUARDIAN" }, //Classes
            new List<string> { "CLERIC", "GUARDIAN", "ARTIFACT", "POWERCELL" }, //SubTypes
            "NORM",//Element
            "Mercurial Heart",//Name
            "Divine Relic\r\n\r\n" +
            "On Enter: Put a buff counter on target Automaton ally you control.",//Effect
            false,//Generated
            0,//CostMemory
            null,//CostReserve
            null,//level
            null,//Life
            null,//Power
            null,//Durability
            null,//Speed
            MercurialHeart));//Image
    }
}
