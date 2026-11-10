using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using AdventurePuzzleKit;

namespace FS_Atmo
{

    public class SimpleOpenClose : MonoBehaviour, IInteractable
    {
        private Animator myAnimator;
        private Animator additionalAnimator;
        public bool objectOpen;
        public bool objectOpenAdditional;
        public GameObject animateAdditional;
        private bool hasAdditional = false;
        float myNormalizedTime;

        [Header("Random Item Spawn")]
        [Tooltip("Child object kept disabled in the drawer. Enabled (and stays enabled) by a successful roll after the drawer fully closes.")]
        public GameObject spawnItem;
        [Range(0f, 100f)] public float spawnChance = 25f;
        [Tooltip("Fires when the item spawns. Hook up any other audio/FX here.")]
        public UnityEngine.Events.UnityEvent onItemSpawned;
        private Coroutine spawnRoutine;


        // Open or close animator state in start depending on selection.
        // Additional object with animator. For example another door when double doors. 
        void Start()
        {

            // If there is no animator in the gameobject itself, get the parent animator.
            myAnimator = GetComponent<Animator>();
            if (myAnimator == null)
            {
                myAnimator = GetComponentInParent<Animator>();
            }


            if (objectOpen == true)
            {
                myAnimator.Play("Open", 0, 1.0f);
            }
            if (animateAdditional != null)
                if (animateAdditional.GetComponent<SimpleOpenClose>())
                {
                    additionalAnimator = animateAdditional.GetComponent<Animator>();
                    hasAdditional = true;
                    objectOpenAdditional = animateAdditional.GetComponent<SimpleOpenClose>().objectOpen;
                }
                else
                {
                    hasAdditional = false;
                }
        }

        // Player clicks object. Method called from SimplePlayerUse script.

        public void ObjectClicked()
        {

            myNormalizedTime = myAnimator.GetCurrentAnimatorStateInfo(0).normalizedTime;

            if (hasAdditional == false)
            {
                if (myNormalizedTime >= 1.0)
                {
                    if (objectOpen == true)
                    {
                        myAnimator.Play("Close", 0, 0.0f);
                        objectOpen = false;
                        StartCloseRoll();
                    }

                    else
                    {
                        myAnimator.Play("Open", 0, 0.0f);
                        objectOpen = true;
                    }
                }
            }

            if (hasAdditional == true && myNormalizedTime >= 1.0)
            {
                if (objectOpen == true)
                {
                    myAnimator.Play("Close", 0, 0.0f);
                    objectOpen = false;
                    StartCloseRoll();
                    animateAdditional.GetComponent<SimpleOpenClose>().objectOpenAdditional = false;

                    if (objectOpenAdditional == true)
                    {
                        additionalAnimator.Play("Close", 0, 0.0f);
                        objectOpenAdditional = false;
                        animateAdditional.GetComponent<SimpleOpenClose>().objectOpen = false;
                        animateAdditional.GetComponent<SimpleOpenClose>().StartCloseRoll();
                    }

                }

                else
                {
                    myAnimator.Play("Open", 0, 0.0f);
                    objectOpen = true;
                    animateAdditional.GetComponent<SimpleOpenClose>().objectOpenAdditional = true;

                    if (objectOpenAdditional == false)
                    {
                        additionalAnimator.Play("Open", 0, 0.0f);
                        objectOpenAdditional = true;
                        animateAdditional.GetComponent<SimpleOpenClose>().objectOpen = true;

                    }

                }

            }

        }

        // Rolls for the hidden item once the close animation has fully finished.
        // A closed drawer is off-screen contents, so no visibility check is needed.
        public void StartCloseRoll()
        {
            if (spawnItem == null || spawnItem.activeSelf) return;
            if (spawnRoutine != null) StopCoroutine(spawnRoutine);
            spawnRoutine = StartCoroutine(CloseRollRoutine());
        }

        private IEnumerator CloseRollRoutine()
        {
            yield return null; // Animator still reports the old state on the frame Play() is called

            Animator anim = myAnimator;
            while (true)
            {
                if (objectOpen) { spawnRoutine = null; yield break; } // reopened before finishing
                AnimatorStateInfo s = anim.GetCurrentAnimatorStateInfo(0);
                if (s.IsName("Close") && s.normalizedTime >= 1f) break;
                yield return null;
            }

            if (Random.value * 100f < spawnChance)
            {
                spawnItem.SetActive(true);
                onItemSpawned?.Invoke();
            }

            spawnRoutine = null;
        }

        // ── IInteractable ──────────────────────────────────────────────
        public void StartLooking() { }
        public void StopInteraction() { }
        public void HandleInputClick() => ObjectClicked();
        public void HandleInputHold() { }
        public void HandleInputStop() { }
    }
}