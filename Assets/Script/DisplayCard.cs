using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;

public class DisplayCard : MonoBehaviour
{
    public List<Card> displayCard = new List<Card> ();
    public int displayId;

    public int id;
    public List<string> types;
    public List<string> classes;
    public List<string> subtypes;
    public string element;
    public string cardname;
    public string effect;
    public string flavor;
    public int costmemory;
    public int costreserve;
    public int level;
    public int life;
    public int durability;
    public string speed;
    

    public Image cardImage;


    void Start()
    {
        if (displayCard.Count == 0)
        {
            displayCard.Add(new Card());  
        }


        if (displayId >= 0 && displayId < CardDatabase.cardList.Count)
        {
            displayCard[0] = CardDatabase.cardList[displayId];
        }
        else
        {
            Debug.LogError($"Invalid displayId {displayId}. Must be between 0 and {CardDatabase.cardList.Count - 1}.");
        }
    }



    void Update()
    {
        if (displayCard.Count > 0)
        {
            var card = displayCard[0];

            id = card.id;
            types = card.types ?? new List<string>();
            classes = card.classes ?? new List<string>();
            subtypes = card.subtypes ?? new List<string>();
            element = card.element ?? string.Empty;
            cardname = card.cardname ?? string.Empty;
            effect = card.effect ?? string.Empty;
            flavor = card.flavor ?? string.Empty;
            costmemory = card.costmemory ?? 0; 
            costreserve = card.costreserve ?? 0; 
            level = card.level ?? 0; 
            life = card.life ?? 0; 
            durability = card.durability ?? 0; 
            speed = card.speed ?? string.Empty;

            
            if (cardImage != null && card.image != null)
            {
                cardImage.sprite = card.image;
            }
        }
    }
}
