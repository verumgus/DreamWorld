using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ManagerSound : MonoBehaviour
{
    private bool soundState = true;
    [SerializeField] private AudioSource soundBG;
    [SerializeField] private AudioSource soundFG;

    [SerializeField] private Sprite soundOn;
    [SerializeField] private Sprite soundOff;

    [SerializeField]private Image muteImage;
   public void SoundControl()
    {
        soundState = !soundState;
        soundBG.enabled = soundState;
        soundFG.enabled = soundState;

        if (soundState)
        {
            muteImage.sprite = soundOn;
        }
        else
        {
            muteImage.sprite = soundOff;
        }
    }

    public void SoundControlSlide(float value)
    {
        soundBG.volume = value;
        soundFG.volume = value - 0.8f;
    }
}
