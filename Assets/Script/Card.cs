#nullable enable
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[System.Serializable]

public class Card 
{
    public int id { get; set; }
    public List<string>? types { get; set; }
    public List<string>? classes { get; set; }
    public List<string>? subtypes { get; set; }
    public string? element { get; set; }
    public string? cardname { get; set; }
    public string? effect { get; set; }
    public bool? generated { get; set; }
    public int? costmemory { get; set; }
    public int? costreserve { get; set; }
    public int? level { get; set; }
    public int? life { get; set; }
    public int? power { get; set; }
    public int? durability { get; set; }
    public string? speed { get; set; }
    public Sprite? image { get; set; }

    public Card()
    {
        
    }

    public Card(int Id, List<string>? Types, List<string>? Classes, List<string>? Subtypes, string? Element, string? CardName, string? Effect,
                bool? Generated, int? CostMemory, int? CostReserve, int? Level, int? Life, int? Power, int? Durability, string? Speed, Sprite? Image)
    {
        id = Id;
        types = Types;
        classes = Classes;
        subtypes = Subtypes;
        element = Element;
        cardname = CardName;
        effect = Effect;
        generated = Generated;
        costmemory = CostMemory;
        costreserve = CostReserve;
        level = Level;
        life = Life;
        power = Power;
        durability = Durability;
        speed = Speed;
        image = Image;
    }
}
