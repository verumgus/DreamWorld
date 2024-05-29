using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MovimentoPlayer : MonoBehaviour
{
    bool esquerda, frente, direita, tras;
    bool noChao, pulo;

    public LayerMask Chao;

    public Rigidbody rb;

    public float velocidade, velocidadeMax, arrasta;
    public float velocidadeRotacao, forcaPulo;

    bool Agachar, Agachando, Correr;

    public float velocidadeAgachado, velocidadeCorre;
    float velocidadeOriginal;

    public Transform cam;

    void Start()
    {
        velocidadeOriginal = velocidade;
    }

    // Update is called once per frame
    void Update()
    {
        ControlePersonagem();
        LimiteMovimento();
        Arrasta();
        TanoChao();
    }

    void TanoChao()
    {
        noChao = Physics.Raycast(transform.position + Vector3.up * 1f, Vector3.down, 2f, Chao);
    }

    private void FixedUpdate()
    {
        MovimentacaoPlayer();
    }

    void MovimentaRotacao()
    {

        if ((new Vector2(rb.velocity.x, rb.velocity.z).magnitude > 0.1f))
        {
            Vector3 HorizontalDir = new Vector3(rb.velocity.x, 0, rb.velocity.z);
            Quaternion rotation = Quaternion.LookRotation(HorizontalDir, Vector3.up);
            transform.rotation = Quaternion.RotateTowards(transform.rotation, rotation, velocidadeRotacao);
        }
    }

    void Arrasta()
    {
        rb.velocity = new Vector3(rb.velocity.x, 0, rb.velocity.z) / (1 + arrasta / 100) + new Vector3(0, rb.velocity.y, 0);

    }

    void MovimentacaoPlayer()
    {
        Quaternion dir = Quaternion.Euler(0, cam.rotation.eulerAngles.y, 0f);

        if (esquerda)
        {
            rb.AddForce(dir * Vector3.left * velocidade);
            esquerda = false;
        }
        if (frente)
        {
            rb.AddForce(dir * Vector3.forward * velocidade);
            frente = false;
        }
        if (direita)
        {
            rb.AddForce(dir * Vector3.right * velocidade);
            direita = false;
        }
        if (tras)
        {
            rb.AddForce(dir * Vector3.back * velocidade);
            tras = false;
        }
        if (pulo && noChao)
        {
            transform.position += Vector3.up * 1f;
            rb.velocity = new Vector3(rb.velocity.x, 0, rb.velocity.y);
            rb.AddForce(Vector3.up * forcaPulo, ForceMode.Impulse);
            pulo = false;
        }

        if (Agachar && !Agachando)
        {
            velocidade = velocidadeAgachado;
            transform.localScale -= new Vector3(0, 0.5f, 0);
            Agachar = false;
            Agachando = true;
        }
        if (Agachar && Agachando)
        {
            velocidade = velocidadeOriginal;
            transform.localScale += new Vector3(0, 0.5f, 0);
            Agachar = false;
            Agachando = false;
        }

        if (Correr && !Agachando)
        {
            Correr = false;
        }
        if (!Correr && !Agachando)
        {
            velocidade = velocidadeOriginal;
        }

    }

    void LimiteMovimento()
    {
        Vector3 velocidadeHorizontal = new Vector3(rb.velocity.x, 0, rb.velocity.z);
        if (velocidadeHorizontal.magnitude > velocidadeMax)
        {
            Vector3 VelocidadeLimite = velocidadeHorizontal.normalized * velocidadeMax;
            rb.velocity = new Vector3(VelocidadeLimite.x, rb.velocity.y, VelocidadeLimite.z);

        }
    }
    void ControlePersonagem()
    {
        if (Input.GetKey(KeyCode.A))
        {
            esquerda = true;
        }
        if (Input.GetKey(KeyCode.W))
        {
            frente = true;
        }
        if (Input.GetKey(KeyCode.D))
        {
            direita = true;
        }
        if (Input.GetKey(KeyCode.S))
        {
            tras = true;
        }
        if (Input.GetKeyDown(KeyCode.Space) && noChao)
        {
            pulo = true;
        }

        if (Input.GetKeyDown(KeyCode.LeftControl))
        {
            Agachar = true;
        }

        if (Input.GetKey(KeyCode.LeftShift) && !Agachando)
        {
            velocidade = velocidadeCorre;
            Correr = true;
        }
    }
}
