using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class HealthBar : MonoBehaviour
{
    public Slider healthSlider;

    public void SetSlider(float Amount)
    {
        healthSlider.value = Amount;
    }

    public void SetSliderMax(float Amount)
    {
        healthSlider.maxValue = Amount;
        SetSlider(Amount);
    }
}
