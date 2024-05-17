using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Controller : MonoBehaviour
{
    private CharacterController controller;
    public Rigidbody rb;

    private Vector3 moveDirection;
    private float rot;



    private Animator animator;

    [SerializeField] private LayerMask layerGround;
    [SerializeField] private Transform groundCheck;
    [SerializeField] private float rCheck;

    [SerializeField] private float maxheght;
    [SerializeField] private float timeMaxHeght;
    private Vector3 yJumpForce;
    private float jumpSpeed;

    //controlladores de estatus 
    public float velocity;
    public float speed;
    private float gravity;
    public float rotSpeed;
    public float speedRun;

    void Start()
    {
        SetGravity();
        controller = GetComponent<CharacterController>();
        animator = GetComponent<Animator>();
        velocity = speed;
        
    }
    
    // Update is called once per frame
    void Update()
    {
        Move();
       GravityForce();

        jumpForce();
    }

    void Move()
    {
        if(controller.isGrounded)
        { 
            if(Input.GetKey(KeyCode.W)) 
                {
                moveDirection = Vector3.forward*velocity;
                animator.SetInteger("transition", 1);
                if (Input.GetKey(KeyCode.LeftShift))
                {
                    velocity = speedRun;
                    animator.SetInteger("transition", 2);
                }
                else
                {
                    velocity = speed;
                    animator.SetInteger("transition", 1);
                }
                
            }

            if(Input.GetKeyUp(KeyCode.W)) 
                {
                moveDirection = Vector3.zero;
                animator.SetInteger("transition", 0);
            }

            if (Input.GetKey(KeyCode.S))
            {
                moveDirection = Vector3.back * velocity;
                animator.SetInteger("transition", -1);
            }

            if (Input.GetKeyUp(KeyCode.S))
                {
                moveDirection = Vector3.zero;
                animator.SetInteger("transition", 0);
            }
                
            
        }
       

        rot += Input.GetAxis("Horizontal")*rotSpeed*Time.deltaTime;
        transform.eulerAngles =new Vector3(0,rot,0);

        moveDirection.y -= gravity * Time.deltaTime;
        moveDirection = transform.TransformDirection(moveDirection);
        

        controller.Move(moveDirection * Time.deltaTime) ;
    }
    private void SetGravity()
    {
        //calculo gravitacional
        gravity = (maxheght * 2) / Mathf.Pow(timeMaxHeght,2);
        jumpSpeed = gravity * timeMaxHeght;
    }
    private void GravityForce()
    {
        yJumpForce += gravity * Time.deltaTime * Vector3.down;
        controller.Move(yJumpForce);

        if (IsGrounded())
        {
            yJumpForce = Vector3.zero;
        }
    }

    private void jumpForce()
    {
        if (IsGrounded())
        {
            if (Input.GetKeyDown(KeyCode.Space))
            {
                animator.SetInteger("transition", 10);              
                
                yJumpForce = jumpSpeed * Vector3.up;
                controller.Move(yJumpForce);
                

            }
        }
       
        
    }
    private bool IsGrounded()
    {
        bool isGrounded = Physics.CheckSphere(groundCheck.position, rCheck, layerGround);
            return isGrounded;
    }
    
}
