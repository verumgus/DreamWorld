using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using UnityEngine;

public class Pulo : MonoBehaviour
{
    [SerializeField] private CharacterController cc;
    [SerializeField] private Animator animator;

    [SerializeField] private LayerMask ground;
    [SerializeField] private Transform GroundCheck;
    [SerializeField] private float radiusCheck;

    [SerializeField] public float Maxheight;
    [SerializeField] public float timetoMaxheight;

    private Vector3 yJumpforce;
    private float yJumpSpeed;
    private float gravity;

    // Start is called before the first frame update
    void Start()
    {
        cc = GetComponent<CharacterController>();
        animator = GetComponent<Animator>();

        SetGravity();

    }

    // Update is called once per frame
    void Update()
    {
        Gravityforce();
        Jump();
    }

    private void SetGravity()
    {
        gravity = (2 * Maxheight) / Mathf.Pow(timetoMaxheight, 2);
        yJumpSpeed = gravity * timetoMaxheight;


    }

    private void Gravityforce()
    {
        yJumpforce += gravity * Time.deltaTime * Vector3.down;
        cc.Move(yJumpforce);

        if (isGrounded() == true) yJumpforce = Vector3.zero;
    }

    private void Jump()
    {
        if (isGrounded() == true)
        {


            if (Input.GetKeyDown(KeyCode.Space))
            {
                yJumpforce = yJumpSpeed * Vector3.up;
                cc.Move(yJumpforce);

                animator.SetBool("Jump", true);

            }
        }
        else
        {
            animator.SetBool("Jump", false);
        }
    }

    private bool isGrounded()
    {
        bool isGrounded = Physics.CheckSphere(GroundCheck.position, radiusCheck, ground);
        return isGrounded;
        
    }

    private void OnDrawGizmos()
    {
        Gizmos.DrawWireSphere(GroundCheck.position, radiusCheck);
    }
}
