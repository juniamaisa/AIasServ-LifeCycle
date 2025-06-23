--------------------------- MODULE MTCP_MEP ---------------------------
EXTENDS Naturals, TLC
CONSTANTS
  NFs,                \* e.g. {nf1,nf2,nf3}
  Versions,           \* e.g. {v1,v2}
  startModel          \* one element of Versions initially "valid"

VARIABLES
  modelState, loadStatus, publishLog,
  inferIssued, feedbackReported

vars == << modelState, loadStatus, publishLog,
           inferIssued, feedbackReported >>

States == {"draft","valid","published","retired"}

(* --helper: is there any model other than v still active? ------------ *)
HasOtherActive(v) ==
  \E w \in Versions :
      /\ w # v
      /\ (modelState[w] = "valid" \/ modelState[w] = "published")

(* ---------------- initial ------------------------------------------ *)
Init ==
  /\ modelState  = [v \in Versions |-> IF v = startModel THEN "valid" ELSE "draft"]
  /\ loadStatus  = [n \in NFs |-> "none"]
  /\ publishLog  = {}
  /\ inferIssued = {}
  /\ feedbackReported = {}

(* ---------------- actions ------------------------------------------ *)
PublishModel(v) ==
  /\ modelState[v] = "valid"
  /\ modelState' = [modelState EXCEPT ![v] = "published"]
  /\ publishLog' = publishLog \cup {v}
  /\ UNCHANGED <<loadStatus, inferIssued, feedbackReported>>

RetireModel(v) ==
  /\ modelState[v] = "published"
  /\ HasOtherActive(v)                       \* prevents last-model dead-lock
  /\ modelState' = [modelState EXCEPT ![v] = "retired"]
  /\ UNCHANGED <<loadStatus, publishLog, inferIssued, feedbackReported>>

LoadModel(n,v) ==
  /\ modelState[v] = "published"
  /\ loadStatus' = [loadStatus EXCEPT ![n] = v]
  /\ UNCHANGED <<modelState, publishLog, inferIssued, feedbackReported>>

Infer(n,v) ==
  /\ loadStatus[n] = v
  /\ inferIssued' = inferIssued \cup {<<n,v>>}
  /\ UNCHANGED <<modelState, loadStatus, publishLog, feedbackReported>>

ReportFeedback(n,v) ==
  /\ <<n,v>> \in inferIssued
  /\ feedbackReported' = feedbackReported \cup {<<n,v>>}
  /\ UNCHANGED <<modelState, loadStatus, publishLog, inferIssued>>

Next ==
      \E v1 \in Versions : PublishModel(v1)
  \/  \E v2 \in Versions : RetireModel(v2)
  \/  \E n1 \in NFs : \E v3 \in Versions : LoadModel(n1,v3)
  \/  \E n2 \in NFs : \E v4 \in Versions : Infer(n2,v4)
  \/  \E n3 \in NFs : \E v5 \in Versions : ReportFeedback(n3,v5)

(* ---------------- properties --------------------------------------- *)
NoStaleLoad ==
  \A n \in NFs :
      LET v == loadStatus[n] IN v = "none" \/ modelState[v] # "retired"

DeadlockFreedom == ENABLED Next           \* now holds because of guard

EventuallyPublished ==
  \A v \in Versions :
      modelState[v] = "valid" => <> (modelState[v] = "published")

EventuallyFeedback ==
  \A n \in NFs : \A v \in Versions :
      (<<n,v>> \in inferIssued) => <> (<<n,v>> \in feedbackReported)

(* ---------------- full spec ---------------------------------------- *)
Spec ==
  Init /\ [][Next]_vars /\ WF_vars(Next)

THEOREM Spec => [] NoStaleLoad
THEOREM Spec => [] DeadlockFreedom
THEOREM Spec => EventuallyPublished
THEOREM Spec => EventuallyFeedback
========================================================================
