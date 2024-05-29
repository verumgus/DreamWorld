using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using System;

public class CicloDiaeNoite : MonoBehaviour
{
    [SerializeField] private Transform luzDirecional;
    [SerializeField] [Tooltip("Duração do Dia em Segundos")] private int duraoDoDia;
    [SerializeField] private TextMeshProUGUI horarioText;

    private float segundos;
    private float multiplicador;
  
    void Start()
    {
        multiplicador = 86400 / duraoDoDia;
    }

    // Update is called once per frame
    void Update()
    {
        segundos += Time.deltaTime * multiplicador;
        if(
            segundos >= 86400)
        {
            segundos = 0f;
        }
        ProcessSky();
        CalcTime();
        
        
    }


    private void ProcessSky()
    {
        float rotationX =Mathf.Lerp(-90, 270, segundos / 86400);
        luzDirecional.rotation = Quaternion.Euler(rotationX, 0, 0);
    }
    private void CalcTime()
    {
        horarioText.text = TimeSpan.FromSeconds(segundos).ToString(@"hh\:mm");
    }
}
