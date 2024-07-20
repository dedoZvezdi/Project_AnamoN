using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;

public class DisplayCard : MonoBehaviour
{
    public List<Card> displayCard = new List<Card>();
    
    public int displayId;

    public List<string> types;
    public List<string> classes;
    public List<string> subtypes;
    public string element;
    public string cardname;
    public string effect;
    public string isToken;
    public string costmemory;
    public string costreserve;
    public string level;
    public string life;
    public string durability;
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

            types = card.types ?? new List<string>();
            classes = card.classes ?? new List<string>();
            subtypes = card.subtypes ?? new List<string>();
            element = card.element ?? string.Empty;
            cardname = card.cardname ?? string.Empty;
            effect = card.effect ?? string.Empty;
            isToken = card.isToken.Value.ToString() ?? string.Empty;
            costmemory = card.costmemory.HasValue ? card.costmemory.Value.ToString() : string.Empty;
            costreserve = card.costreserve.HasValue ? card.costreserve.Value.ToString() : string.Empty;
            level = card.level.HasValue ? card.level.Value.ToString() : string.Empty;
            life = card.life.HasValue ? card.life.Value.ToString() : string.Empty;
            durability = card.durability.HasValue ? card.durability.Value.ToString() : string.Empty;
            speed = card.speed ?? string.Empty;

            if (cardImage != null && card.image != null)
            {
                cardImage.sprite = card.image;
            }
        }
    }
}
