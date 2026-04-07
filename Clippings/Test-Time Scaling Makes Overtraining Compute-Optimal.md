---
title: "Test-Time Scaling Makes Overtraining Compute-Optimal"
source: "https://arxiv.org/html/2604.01411"
author:
published:
created: 2026-04-07
description:
tags:
  - "clippings"
---
Nicholas Roberts <sup>μ</sup>       Sungjun Cho <sup>μ</sup>      Zhiqi Gao <sup>μ</sup>      Tzu-Heng Huang <sup>μ</sup>      Albert Wu <sup>μ</sup>      
Gabriel Orlanski <sup>μ</sup>   Avi Trost <sup>μ</sup>   Kelly Buchanan <sup>σ</sup>   Aws Albarghouthi <sup>μ</sup>   Frederic Sala <sup>μ</sup>  
<sup>μ</sup> University of Wisconsin-Madison     <sup>σ</sup> Stanford University  
Corresponding author: [nick11roberts@cs.wisc.edu](https://arxiv.org/html/2604.01411v1/mailto:nick11roberts@cs.wisc.edu).

###### Abstract

Modern LLMs scale at test-time, e.g. via repeated sampling, where inference cost grows with model size and the number of samples. This creates a trade-off that pretraining scaling laws, such as Chinchilla, do not address. We present Train-to-Test ($T^{2}$) scaling laws that jointly optimize model size, training tokens, and number of inference samples under fixed end-to-end budgets. $T^{2}$ modernizes pretraining scaling laws with pass@ $k$ modeling used for test-time scaling, then jointly optimizes pretraining and test-time decisions. Forecasts from $T^{2}$ are robust over distinct modeling approaches: measuring joint scaling effect on the task loss and modeling impact on task accuracy. Across eight downstream tasks, we find that when accounting for inference cost, optimal pretraining decisions shift radically into the overtraining regime, well-outside of the range of standard pretraining scaling suites. We validate our results by pretraining heavily overtrained models in the optimal region that $T^{2}$ scaling forecasts, confirming their substantially stronger performance compared to pretraining scaling alone. Finally, as frontier LLMs are post-trained, we show that our findings survive the post-training stage, making $T^{2}$ scaling meaningful in modern deployments.

## 1 Introduction

Pretraining scaling laws tell us how to optimally train language models, but not how to deploy them [^14] [^10]. Test-time scaling laws tell us how to optimally allocate compute at deployment, but not how to train models [^30] [^2]. The two have developed largely in isolation, yet are fundamentally coupled. Model size and training duration determine both the quality and cost of inference samples. Models designed to reason through frontier research problems will be sampled from hundreds or thousands of times [^12] [^9]; these should be trained differently from chat models that instantly answer everyday questions.

Should parameter and token counts change if you know how your model will be used at test time? In practice, Chinchilla [^10] scaling laws guide the allocation of pretraining compute for flagship models. However, modern model releases are families spanning a range of sizes [^33] [^8] [^22], with the lower end intentionally overtrained well beyond Chinchilla-optimal ratios to reduce per-query inference cost. This makes them natural candidates for test-time scaling, yet nothing connects pretraining decisions to this inference strategy. No existing scaling law captures the core tradeoff: smaller models are cheaper per sample but weaker per sample, and the benefit of repeated sampling is a highly nonlinear function of per-sample quality.

Unifying pretraining and inference scaling is challenging because the two regimes operate under fundamentally different evaluation criteria. Pretraining is evaluated using the loss, a smooth, continuous quantity. Test-time scaling, by contrast, is evaluated through downstream task metrics such as pass@ $k$ —the probability of producing at least one correct answer in $k$ independent attempts. Should a unified scaling law across pretraining and test-time scaling model the loss or model the pass@ $k$ accuracy?

Prior work has addressed pieces of this problem but not the whole. [^26] extends Chinchilla to account for inference cost, but considers only the aggregate volume of single-pass serving instead of the multiplicative cost and performance gains from repeated sampling. Recent studies empirically show that allocating more inference compute to smaller models via repeated sampling can match or exceed the performance of larger ones [^2] [^30], but they treat pretrained models as given and do not address how they should have been trained. [^28] develop scaling laws that predict pass@ $k$ from pretraining compute, but treat this as forecasting rather than an optimization problem—they predict what performance *will be* for a given model, not what model *should be* trained for a given budget. No existing work jointly optimizes model size, training duration, and the number of inference samples under a single compute budget.

In this work, we close the loop between pre-training and test-time scaling. We propose Train-to-Test ($T^{2}$) scaling laws that predict performance as a function of model size $N$, training tokens $D$, and number of samples $k$, and optimize over all three under a total compute budget that includes both training ($6ND$) and inference ($2Nk$) cost. Following Chinchilla, we evaluate multiple modeling approaches: whether to model the loss or pass@ $k$ as functions of $N$, $D$, and $k$. Although the two approaches are quite different, we find that they agree closely: both suggest substantial overtraining and test-time scaling across our evaluations. We build on an existing set of Chinchilla scaling checkpoints from [^21], extending it into the overtrained regime and assembling a testbed of over 100 models across 12 compute levels spanning three orders of magnitude.

![Refer to caption](https://arxiv.org/html/2604.01411v1/x1.png)

Figure 1: Our T 2 T^{2} scaling laws combine Chinchilla scaling for pretraining with pass@ k modeling for test-time scaling via repeated sampling to obtain optimal pretraining allocations subject to a test-time scaling budget. recommends overtraining compared to Chinchilla.

Using $T^{2}$ scaling laws, we find that *optimal pretraining decisions shift radically into the overtraining regime* when considering test-time compute. When we correct for the cost of repeated sampling, the optimal model is substantially smaller and more overtrained than what Chinchilla prescribes. Our evaluation spans eight tasks covering knowledge, reasoning, and language understanding, on which we investigate three research questions:

1. Should pretraining change if you know your test-time scaling budget? Yes— $T^{2}$ scaling consistently recommends small overtrained models. (§4.1)
2. Does $T^{2}$ extrapolate to overtrained checkpoints? Yes—we overtrain models from scratch and show that they consistently outperform Chinchilla checkpoints. (§4.2)
3. Does $T^{2}$ scaling survive post-training? Yes—we find that compute-optimal trade-offs derived from base models persist after supervised fine-tuning. (§4.3)

To answer these questions, we make the following contributions:

<svg id="S1.p8.pic1" class="ltx_picture" height="448.7" overflow="visible" version="1.1" viewBox="0 0 600 448.7" width="600"><g style="--ltx-stroke-color:#000000;--ltx-fill-color:#000000;" transform="translate(0,448.7) matrix(1 0 0 -1 0 0)" fill="#000000" stroke="#000000" stroke-width="0.4pt"><g style="--ltx-fill-color:#666666;" fill="#666666" fill-opacity="1.0"><path style="stroke:none" d="M 0 3.32 L 0 445.38 C 0 447.21 1.49 448.7 3.32 448.7 L 596.68 448.7 C 598.51 448.7 600 447.21 600 445.38 L 600 3.32 C 600 1.49 598.51 0 596.68 0 L 3.32 0 C 1.49 0 0 1.49 0 3.32 Z"></path></g><g style="--ltx-fill-color:#F9F9F9;" fill="#F9F9F9" fill-opacity="1.0"><path style="stroke:none" d="M 0.55 3.32 L 0.55 430.11 L 599.45 430.11 L 599.45 3.32 C 599.45 1.79 598.21 0.55 596.68 0.55 L 3.32 0.55 C 1.79 0.55 0.55 1.79 0.55 3.32 Z"></path></g><g fill-opacity="1.0" transform="matrix(1.0 0.0 0.0 1.0 12.79 434.6)"><foreignObject style="--ltx-fg-color:#FFFFFF;--ltx-fo-width:41.51em;--ltx-fo-height:0.69em;--ltx-fo-depth:0em;" width="574.41" height="9.61" transform="matrix(1 0 0 -1 0 9.61)" overflow="visible" color="#FFFFFF">Contributions </foreignObject></g><g fill-opacity="1.0" transform="matrix(1.0 0.0 0.0 1.0 12.79 416.68)"><foreignObject style="--ltx-fg-color:#000000;--ltx-fo-width:41.51em;--ltx-fo-height:0.69em;--ltx-fo-depth:29.79em;" width="574.41" height="421.68" transform="matrix(1 0 0 -1 0 9.49)" overflow="visible" color="#000000">• End-to-end scaling: We formalize train-to-test scaling as a joint optimization over model size <math xmlns="http://www.w3.org/1998/Math/MathML" display="inline" data-latex="N"><semantics><mi>N</mi> <annotation>N</annotation></semantics></math>, dataset size <math xmlns="http://www.w3.org/1998/Math/MathML" display="inline" data-latex="D"><semantics><mi>D</mi> <annotation>D</annotation></semantics></math>, and inference compute <math xmlns="http://www.w3.org/1998/Math/MathML" display="inline" data-latex="k"><semantics><mi>k</mi> <annotation>k</annotation></semantics></math> under train and test budgets. • Loss and accuracy scaling: We introduce two complementary approaches: (i) loss- and (ii) accuracy-based formulations that explicitly incorporate inference cost. • Validation on overtrained checkpoints: We train models in the predicted overtrained regime and show improved performance under a range of fixed inference budgets. • Interactions with post-training: The predictions from our scaling approach persist after post-training, even though overtrained models are harder to fine-tune.</foreignObject></g></g></svg>

## 2 Background

Our work connects two important areas: (i) pretraining scaling laws and (ii) test-time sampling strategies after deployment. We begin with their setups then dive into our new modeling techniques. A summary of additional related work can be found in Appendix A.

Chinchilla scaling laws for pretraining. The Chinchilla scaling law [^10] models the pretraining loss as a function of finite model capacity $N$ and dataset size $D$ (number of training tokens): $L(N,D)=E+\frac{A}{N^{\alpha}}+\frac{B}{D^{\beta}}$, where $E$ represents an irreducible loss floor fit for the given data distribution and evaluation setup while the remaining terms capture reducible contributions from $N$ and $D$. The parameters $A$, $B$, $\alpha$, $\beta$, and $E$ are all non-negative and are fit empirically from a grid of training runs. Here, the loss is assumed to be the negative log-likelihood (NLL) over the data distribution: $\mathbb{E}_{(x,y)\sim\mathcal{D}}[-\log(p(y|x))]$ with $p(y|x)$ being the probability assigned by the model. Given a pretraining budget $C_{\text{train}}\approx 6ND$, the *compute-optima* minimize $L$ subject to this constraint, yielding $N^{*}(C_{\text{train}})\propto C_{\text{train}}^{a}$ and $D^{*}(C_{\text{train}})\propto C_{\text{train}}^{b}$ with $a\approx b\approx 0.5$. That is, the optimal model size and training tokens should scale at similar rates as a function of the pretraining compute budget.

Pass@k estimation for test-time scaling. The standard metric for evaluating repeated sampling is pass@ $k$: draw $k$ independent samples from a model and succeed if *any* sample is correct. For a single problem $i$ with per-sample success probability $p_{i}$, the probability of at least one answer in $k$ attempts being correct is $\text{pass@}k_{i}=1-(1-p_{i})^{k}$. Aggregating over a benchmark $\mathcal{D}$ of $M$ problems gives the expected pass@ $k$:

$$
\text{pass@}k_{\mathcal{D}}=\mathbb{E}_{i\sim\mathcal{D}}\left[\text{pass@}k_{i}\right]=\dfrac{1}{M}\sum_{i=1}^{M}\left[1-(1-p_{i})^{k}\right].
$$

## 3 Estimating Optimal Pretraining Allocations for Test-Time Scaling

We present two modeling approaches for $T^{2}$ scaling that answer our central research question: should choices made during pretraining change if you know your test-time scaling budget? In our first approach, we model the impact of repeated sampling on the loss by fitting a parametric function of the negative log pass@ $k$. In our second approach, we model the pass@ $k$ accuracy directly by composing Chinchilla scaling with a pass@ $k$ estimator. In §4, we show that our findings are robust across both approaches. Finally, once we establish these two approaches, we answer our main research question by standardizing the test-time scaling budget: using more repeated samples for smaller models and fewer for larger models. Standardizing the inference budget of test-time scaling across checkpoints allows us to see how optimal pretraining decisions shift in light of test-time scaling considerations. If the optimal pretraining decisions (model size and the number of training tokens) shift compared to those recommended by standard Chinchilla scaling, then the answer to RQ1 is yes: pretraining decisions should change if you know your test-time scaling budget.

We first describe the optimization objectives of our $T^{2}$ approaches. Given a compute budget for training ($C_{\text{train}}$) and inference ($C_{\text{inf}}$), the optimization problem in terms of the NLL is:

$$
\min_{N,D,k}\;\;L(N,D,k)\qquad\text{s.t.}\quad 6ND\leq C_{\text{train}}\,\,\text{ and }\,\,2Nk\leq C_{\text{inf}},
$$

or similarly, in terms of the pass@ $k$ accuracy:

$$
\max_{N,D,k}\;\;\text{Acc}(N,D,k)\qquad\text{s.t.}\quad 6ND\leq C_{\text{train}}\,\,\text{ and }\,\,2Nk\leq C_{\text{inf}}.
$$

$L(N,D,k)$ and $\text{Acc}(N,D,k)$ represent the aggregated NLL and accuracy respectively, as functions of model capacity $N$, dataset size $D$, and number of sampling attempts $k$.

### 3.1 Approach 1: T2T^{2} as a Parametric Model of the Task Loss

Our first approach models the loss as a function of the parameter count $N$, training tokens $D$, and the number of repeated samples $k$ used at test-time in order to optimize Equation 1. First, in order to make repeated sampling compatible with the negative log likelihood (NLL), we rewrite the single-sample probability in terms of the probability that the target outcome is obtained at least once under $k$ repeated samples, following prior work on pass@ $k$ [^3] [^2] [^5] [^27]. That is, working with the definition of $\text{pass@}k_{i}$ allows us to define the corresponding NLL-style objective under repeated sampling as

$$
\mathbb{E}_{i\sim\mathcal{D}_{\text{task}}}[-\log\text{pass@}k_{i}]=\mathbb{E}_{i\sim\mathcal{D}_{\text{task}}}\left[-\log\left(1-(1-p_{i})^{k}\right)\right],
$$

where $\mathcal{D}_{\text{task}}$ is a distribution over samples $i$ representing a downstream task.

With this in place, we can model the negative log pass@ $k$ as an extension of the Chinchilla scaling law, $\widehat{L}(N,D)$ by adding a power-law term in $k$:

$$
\widehat{L}(N,D,k)=\widehat{L}(N,D)+\frac{G}{k^{\gamma}}=E+\frac{A}{N^{\alpha}}+\frac{B}{D^{\beta}}+\frac{G}{k^{\gamma}}.
$$

We choose this model because prior work has found that the negative log pass@ $k$ contribution from $k$ yields power law scaling <sup>1</sup> under an assumption that the task difficulty distribution can be modeled by a Beta distribution, which has been found to hold in practice [^2] [^27]. This has convenient properties when combined with the other power law terms in $N$ and $D$ in the Chinchilla scaling law:

First, when $k=1$, we recover standard Chinchilla scaling:

$$
\widehat{L}(N,D,1)=E^{\prime}+\frac{A}{N^{\alpha}}+\frac{B}{D^{\beta}}=\widehat{L}(N,D),
$$

where $E^{\prime}=E+G$ absorbs the additional constant. Second, a property of Chinchilla scaling is that as $N,D\to\infty$, the model approaches the ‘irreducible loss’ term $E$. Given its power law form, this is still true when $k$ approaches infinity alongside $N$ and $D$.

### 3.2 Approach 2: T2T^{2} as a Parametric Model of the Task Accuracy

While the previous model is simple, it trades off interpretability—practitioners often value pass@ $k$ forecasts due to their interpretation as the likelihood of solving a problem given a certain compute investment. Our second approach addresses this by modeling the pass@ $k$ directly as an accuracy-like metric as a function of $N$, $D$, and $k$, which optimizes Equation 2.

A naive approach to modeling pass@ $k$ might be to begin with $\widehat{L}(N,D)$, and simply map the NLL to accuracy $p$ for the same task, then compute $\text{pass@}k=1-(1-p)^{k}$. Prior work has shown that the relationship between the mean NLL and the mean accuracy can be well approximated using a fitted sigmoid [^7]. In other words, we can model the mean single-pass task accuracy, $\mathbb{E}_{\mathcal{D}_{\text{task}}}[\text{Acc}(N,D)]$, as $\sigma_{\theta}(\widehat{L}(N,D))$ with a parameterized sigmoid $\sigma_{\theta}$ fit to pairs of NLL and accuracy values on the task distribution across the model population. So this naive model of the pass@ $k$ might take the following form:

$$
\widehat{\text{Acc}}_{\text{naive}}(N,D,k)=1-(1-\sigma_{\theta}(L(N,D)))^{k}.
$$

However, our goal is instead to obtain an estimator of the mean pass@ $k$ accuracy, $\mathbb{E}_{\mathcal{D}_{\text{task}}}[\text{Acc}(N,D,k)]$ that depends on the scaling parameters, rather than the single-pass accuracy, so this naive model overestimates due to the concavity of the pass@ $k$:

$$
\displaystyle 1-(1-\mathbb{E}_{\mathcal{D}_{\text{task}}}[\text{Acc}(N,D)])^{k}
$$
 
$$
\displaystyle\geq\mathbb{E}_{\mathcal{D}_{\text{task}}}[1-(1-\text{Acc}(N,D))^{k}]
$$
 
$$
\displaystyle=\mathbb{E}_{\mathcal{D}_{\text{task}}}[\text{Acc}(N,D,k)].
$$

A simple way to avoid overestimating the pass@ $k$ would be to directly use the per-question probabilities from model likelihoods, which would allow us to compute the mean pass@ $k$ exactly. However, our goal is a scaling law, a parametric model that can forecast pass@ $k$ at unevaluated $(N,D,k)$ configurations. This requires us to model the distribution of per-question probabilities and how this distribution varies with model size and training tokens.

Intuitively, we want to account for the natural spread of difficulty between tasks in our data distribution. We do this by modeling the per-question single-pass accuracies as a Beta distribution, following prior work [^15]. We model $\text{Acc}(N,D)\sim\mathrm{Beta}(a_{N,D},b_{N,D})$, and parameters $a_{N,D}$ with $b_{N,D}$ related to $N$ and $D$ via the NLL, which we model as a Beta regression problem. Using the mean ($\mu$) and sample size ($\nu$) parameterization of the Beta distribution, we model $\mu\in(0,1)$ and $\nu\in(0,\infty)$ using standard link functions from Beta regression: a logit link for the mean (which we rescale with an additional parameter), and a log link for the sample size. We relate this to the loss by using the Chinchilla loss estimate as our linear predictor. This yields the following parameterization of $a_{N,D}$ and $b_{N,D}$:

$$
\displaystyle\mu_{N,D}
$$
 
$$
\displaystyle=\sigma_{\theta}(\widehat{L}(N,D))=\frac{\theta_{2}}{1+\exp\bigl(\theta_{1}\cdot(\widehat{L}(N,D)-\theta_{0})\bigr)},
$$
$$
\displaystyle\nu_{N,D}
$$
 
$$
\displaystyle=\exp(\theta_{3}+\theta_{4}\cdot\widehat{L}(N,D)),
$$
$$
\displaystyle a_{N,D}
$$
 
$$
\displaystyle=\mu_{N,D}\nu_{N,D},
$$
$$
\displaystyle b_{N,D}
$$
 
$$
\displaystyle=(1-\mu_{N,D})\nu_{N,D}.
$$

Finally, using this model of the single-pass accuracy, we obtain the following pass@ $k$ model via properties of the Beta distribution:<sup>2</sup>

$$
\displaystyle\widehat{\text{Acc}}(N,D,k)
$$
 
$$
\displaystyle=\mathbb{E}_{\text{Acc}(N,D)\sim\mathrm{Beta}(a_{N,D},b_{N,D})}\bigl[1-(1-\text{Acc}(N,D))^{k}\bigr]
$$
 
$$
\displaystyle=1-\mathbb{E}_{\text{Acc}(N,D)\sim\mathrm{Beta}(a_{N,D},b_{N,D})}\bigl[(1-\text{Acc}(N,D))^{k}\bigr]
$$
 
$$
\displaystyle=1-\frac{\mathrm{B}(a_{N,D},\,b_{N,D}+k)}{\mathrm{B}(a_{N,D},\,b_{N,D})}
$$
 
$$
\displaystyle=1-\frac{\mathrm{B}(\mu_{N,D}\nu_{N,D},\,(1-\mu_{N,D})\nu_{N,D}+k)}{\mathrm{B}(\mu_{N,D}\nu_{N,D},\,(1-\mu_{N,D})\nu_{N,D})}.
$$

### 3.3 Inference Cost Correction

We equalize our $T^{2}$ scaling laws over an inference budget, $C_{\text{inf}}$, measured as the inference FLOPs per-token served. Just as the pretraining cost, $C_{\text{train}}=6ND$, scales multiplicatively as a function of $N$ and the number of training tokens $D$, the inference budget $C_{\text{inf}}$ scales multiplicatively in $k$ and approximately $2N$ FLOPs for a forward pass:

$$
C_{\text{inf}}=2Nk.
$$

Then for a fixed budget $C_{\text{inf}}$, this gives us

$$
k=\frac{C_{\text{inf}}}{2N},
$$

where smaller models are allocated more repeated samples compared to larger models, subject to the same inference budget. We plug this into both of our $T^{2}$ scaling approaches, which gives us our inference-corrected loss model:<sup>3</sup>

<svg id="S3.SS3.p2.pic1" class="ltx_picture" height="70.18" overflow="visible" version="1.1" viewBox="0 0 600 70.18" width="600"><g style="--ltx-stroke-color:#000000;--ltx-fill-color:#000000;" transform="translate(0,70.18) matrix(1 0 0 -1 0 0)" fill="#000000" stroke="#000000" stroke-width="0.4pt"><g style="--ltx-fill-color:#0000FF;" fill="#0000FF" fill-opacity="1.0"><path style="stroke:none" d="M 0 4.63 L 0 65.55 C 0 68.11 2.07 70.18 4.63 70.18 L 595.37 70.18 C 597.93 70.18 600 68.11 600 65.55 L 600 4.63 C 600 2.07 597.93 0 595.37 0 L 4.63 0 C 2.07 0 0 2.07 0 4.63 Z"></path></g><g style="--ltx-fill-color:#FFFFFF;" fill="#FFFFFF" fill-opacity="1.0"><path style="stroke:none" d="M 0.69 4.63 L 0.69 48.62 L 599.31 48.62 L 599.31 4.63 C 599.31 2.45 597.55 0.69 595.37 0.69 L 4.63 0.69 C 2.45 0.69 0.69 2.45 0.69 4.63 Z"></path></g><g fill-opacity="1.0" transform="matrix(1.0 0.0 0.0 1.0 20.38 55.94)"><foreignObject style="--ltx-fg-color:#FFFFFF;--ltx-fo-width:40.42em;--ltx-fo-height:0.69em;--ltx-fo-depth:0.19em;" width="559.25" height="12.3" transform="matrix(1 0 0 -1 0 9.61)" overflow="visible" color="#FFFFFF">Approach 1 </foreignObject></g><g fill-opacity="1.0" transform="matrix(1.0 0.0 0.0 1.0 20.38 19.93)"><foreignObject style="--ltx-fg-color:#000000;--ltx-fo-width:40.42em;--ltx-fo-height:1.22em;--ltx-fo-depth:0.54em;" width="559.25" height="24.31" transform="matrix(1 0 0 -1 0 16.88)" overflow="visible" color="#000000"><math xmlns="http://www.w3.org/1998/Math/MathML" display="block" data-latex="\widehat{L}\left(N,D,\frac{C_{\text{inf}}}{2N}\right)=\widehat{L}(N,D)+\frac{G}{k^{\gamma}}=E+\frac{A}{N^{\alpha}}+\frac{B}{D^{\beta}}+\frac{G}{\left(\frac{C_{\text{inf}}}{2N}\right)^{\gamma}},"><semantics><mrow><mrow><mrow><mover accent="true"><mi>L</mi> <mo>^</mo></mover> <mo lspace="0em" rspace="0em"></mo><mrow><mo>(</mo><mi>N</mi><mo>,</mo><mi>D</mi><mo>,</mo><mfrac><msub><mi>C</mi> <mtext>inf</mtext></msub> <mrow><mn>2</mn> <mo lspace="0em" rspace="0em"></mo><mi>N</mi></mrow></mfrac><mo>)</mo></mrow></mrow> <mo>=</mo> <mrow><mrow><mover accent="true"><mi>L</mi> <mo>^</mo></mover> <mo lspace="0em" rspace="0em"></mo><mrow><mo stretchy="false">(</mo><mi>N</mi><mo>,</mo><mi>D</mi><mo stretchy="false">)</mo></mrow></mrow> <mo>+</mo> <mfrac><mi>G</mi> <msup><mi>k</mi> <mi>γ</mi></msup></mfrac></mrow> <mo>=</mo> <mrow><mi>E</mi> <mo>+</mo> <mfrac><mi>A</mi> <msup><mi>N</mi> <mi>α</mi></msup></mfrac> <mo>+</mo> <mfrac><mi>B</mi> <msup><mi>D</mi> <mi>β</mi></msup></mfrac> <mo>+</mo> <mfrac><mi>G</mi> <msup><mrow><mo>(</mo><mfrac><msub><mi>C</mi> <mtext>inf</mtext></msub> <mrow><mn>2</mn> <mo lspace="0em" rspace="0em"></mo><mi>N</mi></mrow></mfrac><mo>)</mo></mrow> <mi>γ</mi></msup></mfrac></mrow></mrow><mo>,</mo></mrow><annotation>\widehat{L}\left(N,D,\frac{C_{\text{inf}}}{2N}\right)=\widehat{L}(N,D)+\frac{G}{k^{\gamma}}=E+\frac{A}{N^{\alpha}}+\frac{B}{D^{\beta}}+\frac{G}{\left(\frac{C_{\text{inf}}}{2N}\right)^{\gamma}},</annotation></semantics></math></foreignObject></g></g></svg>

and our inference-corrected pass@ $k$ accuracy model:

<svg id="S3.SS3.p4.pic1" class="ltx_picture" height="75.56" overflow="visible" version="1.1" viewBox="0 0 600 75.56" width="600"><g style="--ltx-stroke-color:#000000;--ltx-fill-color:#000000;" transform="translate(0,75.56) matrix(1 0 0 -1 0 0)" fill="#000000" stroke="#000000" stroke-width="0.4pt"><g style="--ltx-fill-color:#FF0000;" fill="#FF0000" fill-opacity="1.0"><path style="stroke:none" d="M 0 4.63 L 0 70.93 C 0 73.49 2.07 75.56 4.63 75.56 L 595.37 75.56 C 597.93 75.56 600 73.49 600 70.93 L 600 4.63 C 600 2.07 597.93 0 595.37 0 L 4.63 0 C 2.07 0 0 2.07 0 4.63 Z"></path></g><g style="--ltx-fill-color:#FFFFFF;" fill="#FFFFFF" fill-opacity="1.0"><path style="stroke:none" d="M 0.69 4.63 L 0.69 54.01 L 599.31 54.01 L 599.31 4.63 C 599.31 2.45 597.55 0.69 595.37 0.69 L 4.63 0.69 C 2.45 0.69 0.69 2.45 0.69 4.63 Z"></path></g><g fill-opacity="1.0" transform="matrix(1.0 0.0 0.0 1.0 20.38 61.33)"><foreignObject style="--ltx-fg-color:#FFFFFF;--ltx-fo-width:40.42em;--ltx-fo-height:0.69em;--ltx-fo-depth:0.19em;" width="559.25" height="12.3" transform="matrix(1 0 0 -1 0 9.61)" overflow="visible" color="#FFFFFF">Approach 2 </foreignObject></g><g fill-opacity="1.0" transform="matrix(1.0 0.0 0.0 1.0 20.38 19.67)"><foreignObject style="--ltx-fg-color:#000000;--ltx-fo-width:40.42em;--ltx-fo-height:1.63em;--ltx-fo-depth:0.52em;" width="559.25" height="29.69" transform="matrix(1 0 0 -1 0 22.52)" overflow="visible" color="#000000"><math xmlns="http://www.w3.org/1998/Math/MathML" display="block" data-latex="\widehat{\text{Acc}}\left(N,D,\frac{C_{\text{inf}}}{2N}\right)=1-\frac{\mathrm{B}(\mu_{N,D}\nu_{N,D},\,(1-\mu_{N,D})\nu_{N,D}+\frac{C_{\text{inf}}}{2N})}{\mathrm{B}(\mu_{N,D}\nu_{N,D},\,(1-\mu_{N,D})\nu_{N,D})}."><semantics><mrow><mrow><mrow><mover accent="true"><mtext>Acc</mtext> <mo>^</mo></mover> <mo lspace="0em" rspace="0em"></mo><mrow><mo>(</mo><mi>N</mi><mo>,</mo><mi>D</mi><mo>,</mo><mfrac><msub><mi>C</mi> <mtext>inf</mtext></msub> <mrow><mn>2</mn> <mo lspace="0em" rspace="0em"></mo><mi>N</mi></mrow></mfrac><mo>)</mo></mrow></mrow> <mo>=</mo> <mrow><mn>1</mn> <mo>−</mo> <mfrac><mrow><mi mathvariant="normal">B</mi> <mo lspace="0em" rspace="0em"></mo><mrow><mo stretchy="false">(</mo><mrow><msub><mi>μ</mi> <mrow><mi>N</mi><mo>,</mo><mi>D</mi></mrow></msub> <mo lspace="0em" rspace="0em"></mo><msub><mi>ν</mi> <mrow><mi>N</mi><mo>,</mo><mi>D</mi></mrow></msub></mrow><mo rspace="0.337em">,</mo><mrow><mrow><mrow><mo stretchy="false">(</mo><mrow><mn>1</mn> <mo>−</mo> <msub><mi>μ</mi> <mrow><mi>N</mi><mo>,</mo><mi>D</mi></mrow></msub></mrow><mo stretchy="false">)</mo></mrow> <mo lspace="0em" rspace="0em"></mo><msub><mi>ν</mi> <mrow><mi>N</mi><mo>,</mo><mi>D</mi></mrow></msub></mrow> <mo>+</mo> <mfrac><msub><mi>C</mi> <mtext>inf</mtext></msub> <mrow><mn>2</mn> <mo lspace="0em" rspace="0em"></mo><mi>N</mi></mrow></mfrac></mrow><mo stretchy="false">)</mo></mrow></mrow> <mrow><mi mathvariant="normal">B</mi> <mo lspace="0em" rspace="0em"></mo><mrow><mo stretchy="false">(</mo><mrow><msub><mi>μ</mi> <mrow><mi>N</mi><mo>,</mo><mi>D</mi></mrow></msub> <mo lspace="0em" rspace="0em"></mo><msub><mi>ν</mi> <mrow><mi>N</mi><mo>,</mo><mi>D</mi></mrow></msub></mrow><mo rspace="0.337em">,</mo><mrow><mrow><mo stretchy="false">(</mo><mrow><mn>1</mn> <mo>−</mo> <msub><mi>μ</mi> <mrow><mi>N</mi><mo>,</mo><mi>D</mi></mrow></msub></mrow><mo stretchy="false">)</mo></mrow> <mo lspace="0em" rspace="0em"></mo><msub><mi>ν</mi> <mrow><mi>N</mi><mo>,</mo><mi>D</mi></mrow></msub></mrow><mo stretchy="false">)</mo></mrow></mrow></mfrac></mrow></mrow><mo lspace="0em">.</mo></mrow><annotation>\widehat{\text{Acc}}\left(N,D,\frac{C_{\text{inf}}}{2N}\right)=1-\frac{\mathrm{B}(\mu_{N,D}\nu_{N,D},\,(1-\mu_{N,D})\nu_{N,D}+\frac{C_{\text{inf}}}{2N})}{\mathrm{B}(\mu_{N,D}\nu_{N,D},\,(1-\mu_{N,D})\nu_{N,D})}.</annotation></semantics></math></foreignObject></g></g></svg>

Now for both models, we can choose an inference budget $C_{\text{inf}}$, and observe the pretraining decisions that optimize both the pretraining and inference budgets $C_{\text{train}}$ and $C_{\text{inf}}$. We represent Approach 1 in blue and Approach 2 in red for consistency with our Figures.

## 4 Experiments

In this section, we provide experimental results addressing the three research questions about our $T^{2}$ scaling approaches.First, in §4.1, we show that if you know your test-time scaling budget prior to pretraining, you should overtrain significantly beyond the standard Chinchilla recommendation of 20 tokens per parameter. In §4.2, we validate our predictions against overtrained checkpoints that extend standard Chinchilla scaling suites, showing that our scaling approaches extrapolate to the optimal regions that they predict. Finally, in §4.3, we show that overtraining predictions from our $T^{2}$ approaches persist after post-training. We fit $T^{2}$ scaling to checkpoints from [^21], which we extend with additional overtrained checkpoints, all trained on RefinedWeb [^20].

Tasks. We evaluate $T^{2}$ across eight real and synthetic tasks that we select to be simple enough for small base models, as all of our checkpoints have fewer than 1B parameters. The real tasks that we evaluate include the OpenAI variant of LAMBADA [^19] [^23], ARC-Easy [^4], SciQ [^13], and OpenBookQA [^17]. We also evaluate on four synthetic tasks: simple knowledge recall, multi-step arithmetic reasoning, commonsense causal reasoning, and spatial reasoning, each consisting of 1,000 fill-in-the-blank or short completion questions that were generated using GPT-5 and Claude Opus 4.6. We provide additional task details in Appendix E. Unless otherwise noted, we present macro averaged results over all tasks.

![Refer to caption](https://arxiv.org/html/2604.01411v1/x2.png)

Figure 2: Optimal pretraining forecasts predicted by both T 2 T^{2} approaches, compared to 10. (Left) Optimal tokens per parameter (including the 20 tokens per parameter rule of thumb used by practitioners), (Middle) Optimal model sizes. (Right) Optimal training set sizes. Both approaches forecast extreme overtraining.

### 4.1 RQ1: Should Pretraining Change if You Know Your Test-Time Scaling Budget?

We evaluate RQ1 by comparing the predictions from $T^{2}$ to Chinchilla scaling and find that if you know your test-time scaling budget, you should significantly overtrain.

Setup. We fit both $T^{2}$ approaches to a suite of 106 checkpoints ranging in size from 5M to 901M parameters trained on roughly 50M to 120B tokens. Next, we set the per-token inference budget $C_{\text{inf}}=140\text{B}$ FLOPs, or approximately the cost of a single forward pass using the 70B Chinchilla model [^10]. Finally, to compare $T^{2}$ forecasts to Chinchilla, we extrapolate the predictions from our $T^{2}$ approaches and standard Chinchilla scaling beyond our scaling suite to $10^{25}$ FLOPs. Using the same fits, we visualize pretraining isoFLOP profiles for both approaches. We compare the standard single-pass setting ($k{=}1$) to the inference-corrected setting with $C_{\text{inf}}=2\times 10^{9}$ FLOPs and $k=\frac{C_{\text{inf}}}{2N}$. Each of the 12 isoFLOP curves traces out a fixed pretraining budget $C_{\text{train}}$ by varying $N$ and $D$ subject to $C_{\text{train}}=6ND$. We plot the Chinchilla optimal frontier in black and that of $T^{2}$ in red. Results are macro averaged across all eight tasks. Individual scaling fits for each task across different budgets can be found in Appendix B.

Results. Our results are shown in Figure 2 and Figure 3. Figure 2 shows that we can answer RQ1 in the affirmative: both $T^{2}$ approaches forecast models that are dramatically smaller and more overtrained than what Chinchilla prescribes. We additionally confirm that the Chinchilla scaling fit is consistent with [^10] by overlaying the 70B Chinchilla hero run model described in their paper, alongside the 20 tokens per parameter rule of thumb. Despite modeling fundamentally different quantities (NLL vs accuracy), both $T^{2}$ recommend extreme overtraining, with Approach 2 recommending more aggressive overtraining than Approach 1. Figure 3 shows isoFLOP curves under our $T^{2}$ approaches, how the overtraining trend develops within our scaling population. At every compute scale, the optimal frontier of both $T^{2}$ approaches shifts considerably toward smaller overtrained models with more repeated samples compared to the Chinchilla optimum. When inference-corrected, we see that the Chinchilla optimal frontier exhibits non-monotonic improvement in $C_{\text{train}}$. This is consistent with the findings of [^30], showing that smaller models with more test-time compute can outperform larger models. On the other hand, $T^{2}$ shows both stronger and consistently monotonic improvement, as we jointly model pretraining and test-time scaling. These results confirm that if you know your test-time scaling budget, you should substantially overtrain compared to Chinchilla optimal pretraining.

![Refer to caption](https://arxiv.org/html/2604.01411v1/x3.png)

Figure 3: T 2 T^{2} scaling across all of our evaluation tasks. Both approaches improve monotonically over Chinchilla scaling, while Chinchilla exhibits non-monotonic scaling in C train C\_{\\text{train}}.

### 4.2 RQ2: Does T2T^{2} Scaling Extrapolate to Overtrained Checkpoints?

Next, we evaluate RQ2 by fitting both $T^{2}$ approaches to standard Chinchilla scaling checkpoints and measuring the performance of extrapolation to overtrained checkpoints.

Setup. We fit both of our $T^{2}$ approaches to a suite of 85 Chinchilla scaling checkpoints from [^21] (which stop short of the optimal overtraining regime that $T^{2}$ predicts) and measure the relative absolute error of extrapolating the predictions to 21 overtrained checkpoints that we train using an identical pretraining setup. We include training details and the exact checkpoint grid in Appendix C. We also compare the empirical best overtrained checkpoint (among our 21) in the inference-corrected regime and compare it to the empirical Chinchilla optimal checkpoint at a pretraining budget of $C_{\text{train}}=2.56\times 10^{19}$ across all eight tasks. We set $C_{\text{inf}}=2\times 10^{9}$ for all of the above.

Results. Our extrapolation results are shown in Figure 4 and empirical checkpoint pass@ $k$ results are shown in Table 1. Figure 4 shows that our $T^{2}$ approaches both extrapolate to the 16 new overtrained checkpoints. While both approaches somewhat overestimate performance, Approach 1 extrapolates better than Approach 2, with a relative error of 2.8% compared to 8.4%. Table 1 shows that our best small overtrained checkpoints always outperform the Chinchilla optimal checkpoints when inference corrected, across all eight tasks. This confirms that $T^{2}$ extrapolates to real overtrained checkpoints, and that this phenomenon is not just an artifact of our $T^{2}$ approaches.

![Refer to caption](https://arxiv.org/html/2604.01411v1/x4.png)

Figure 4: Extrapolating 21 checkpoints to the overtraining regime.

### 4.3 RQ3: Does T2T^{2} Scaling Survive Post-Training?

Finally, we evaluate RQ3 by showing that our findings persist after post-training.

Setup. We explore two canonical post-training techniques: standard fine-tuning (FT) and supervised fine-tuning (SFT), where we only fine-tune on the targets. We post-train on the three real tasks that have a standard training set: ARC-Easy, SciQ, and OpenBookQA, and report improved performance on the test sets for each of these. Additional post-training details can be found in Appendix D. We allocate the same number of training steps to each checkpoint, rather than scaling training based on FLOPs, since we ultimately train to convergence. After post-training, we fit both $T^{2}$ approaches to the FT and SFT checkpoints and evaluate their optimal tokens per parameter frontier compared to base models under $T^{2}$ scaling and the Chinchilla frontier. Finally, like in RQ2, we compare the best overtrained FT and SFT checkpoints to the Chinchilla optimal checkpoints for each task.

Results. Our results are shown in Figure 5 and Table 2. We see in Figure 5 that the optimal frontier continues to shift toward smaller overtrained models with more test-time samples across all three tasks and methods. Again, we find that these results are consistent between Approach 1 and Approach 2. On the other hand, we find that the optimal overtraining recommendation is somewhat subdued compared to $T^{2}$ on the base models alone, but not enough to shift it back to the original Chinchilla recommendation. The finding that it is subdued is consistent with prior work showing that overtrained models are harder to fine-tune [^31]. Finally, we see in Table 2 that our best overtrained checkpoints still outperform the Chinchilla optimal checkpoints after post-training, and that performance improves across the board compared to the same analysis on base models in Table 1. This confirms that our findings with $T^{2}$ scaling persist after post-training.

![Refer to caption](https://arxiv.org/html/2604.01411v1/x5.png)

Figure 5: T 2 T^{2} overtraining findings survive post-training. The optimal frontier is slightly subdued compared to base models, which is consistent with 31.

## 5 Conclusion

In this work, we have presented $T^{2}$ scaling laws that jointly optimize model size, training tokens, and the number of repeated samples at test-time under fixed pretraining and inference budgets. We find that when test-time compute via repeated sampling is accounted for during pretraining decisions, the optimal model is substantially smaller and more overtrained than what standard Chinchilla scaling prescribes. This finding is consistent across two complementary modeling approaches: Approach 1 which models the NLL, and Approach 2 which models the pass@ $k$ accuracy directly. We validated this across eight real and synthetic downstream tasks, validated that $T^{2}$ scaling extrapolates to the overtraining regime where its optima are predicted, and that our findings persist after post-training. Based on our findings, we offer a recommendation to practitioners: if you know your test-time scaling budget with repeated sampling, you should train a smaller model for longer, and $T^{2}$ scaling offers a blueprint for doing so. In future work, we plan to validate our prescribed overtraining recipes at larger scales, account for transformer-specific inference cost models, and explicitly model the role of post-training in $T^{2}$ scaling.

## References

## Appendix Roadmap

Our appendix is structured as follows. We begin with related work in Appendix A, followed by Appendix B, which presents per-task scaling law analyses. We next turn to experimental details: Appendix C and Appendix D describe our pretraining and post-training setups, respectively, while Appendix E provides descriptions of all evaluation tasks employed in our study. Finally, Appendix F presents the details of our $T^{2}$ scaling fitting methodology.

## Appendix A Related Work

Our work sits at the intersection of three research threads: (i) pretraining scaling laws, (ii) test-time scaling, and (iii) overtrained models.

### A.1 Pretraining Scaling Laws

[^14] established that model loss follows predictable power laws as a function of model size and training data. [^10] (Chinchilla) refined this into compute-optimal training recipes, prescribing how model size and token count should scale together under a fixed compute budget. Recent extensions has broadened the scope of scaling law modeling: studying data quality and quantity [^6], incorporating downstream task accuracy [^11] [^1], decomposing scaling behaviors across knowledge and reasoning skills [^24], and extending to multimodal settings [^29]. These frameworks, however, treat inference as an afterthought—optimizing for a model that is trained once and queried once. [^26] take a step toward deployment-aware scaling by folding inference serving volume into the compute-optimal recipe, yet their analysis is limited to single-pass queries. We modernize this line of work, where the optimal training decisions must account for both the cost and the compounding performance gains of drawing multiple inference samples.

### A.2 Test-Time Scaling

Beyond scaling pretraining compute, recent work has increasingly focused on investing computation at inference time [^30] [^35] [^12] [^18]. This test-time paradigm often focuses on the search for a correct reasoning path rather than the model’s inherent knowledge and can broadly be categorized into three regimes: (i) parallel scaling, which uses consensus through self-consistency [^2], or verification over multiple independent responses [^25]; (ii) sequential scaling, which refines reasoning through iterative improvements or hierarchical pruning [^34] [^16]; and (iii) internal scaling, which allows the model to dynamically adjust generation depth based on task difficulty [^12]. In this work, we focus on parallel repeated sampling—the most common form of test-time scaling—and incorporate pretraining compute budget to jointly optimize allocation decisions.

### A.3 Overtraining

[^10] (Chinchilla) prescribes a compute-optimal ratio of roughly 20 training tokens per model parameter, yet modern models release routinely deviate from this blueprint by training smaller models on far more tokens than recommended. This deliberate overtraining is motivated by inference efficiency: a smaller model costs less per query at deployment. Recent model families illustrate this trend—Llama-2-7B [^33] was trained on 2T tokens ($\sim$ 290 $\times$ the recommended ratio); Google’s Gemma-7B [^32] was trained on 6T tokens ($\sim$ 857 $\times$), and its successor Gemma 2-9B [^32] on 8T tokens ($\sim$ 889 $\times$)—with OLMo [^8] following a similar philosophy. Our work complements these findings by examining overtraining through a different lens: rather than studying its effect on post-training [^31], we show that overtraining is actively *beneficial* when models are deployed with a repeated-sampling inference budget, and we provide a principled framework for determining how much to overtrain given a joint train-and-test compute allocation.

## Appendix B Per-Task Analysis

We present isoFLOP profiles for each of the individual tasks in our evaluation suite in Figure 6 for Approach 1 and Figure 7 for Approach 2. We find that overtraining predictions are relatively stable across inference budgets for both approaches.

![Refer to caption](https://arxiv.org/html/2604.01411v1/figs/appendix/plots_colm/arc_easy_nll/chinchilla_extension/arc_easy_nll_analytical_overlay.png)

Figure 6: Approach 1 IsoFLOP profiles across different scaling budgets for all eight tasks.

![Refer to caption](https://arxiv.org/html/2604.01411v1/figs/appendix/plots_colm/arc_easy_nll/beta_passk/arc_easy_nll_analytical_overlay.png)

Figure 7: Approach 2 IsoFLOP profiles across different scaling budgets for all eight tasks.

## Appendix C Pretraining Details

In this section, we provide details of our pretraining setup and scaling grid.

### C.1 Checkpoint Scaling Grid

Figure 8 shows our checkpoint grid, comprising pretrained checkpoints from [^21] alongside additional overtrained checkpoints we pretrained in this work. Model sizes range from 5M to 901M parameters, and training FLOPs span $1.25\times 10^{16}$ to $2.56\times 10^{19}$. Each cell reports the number of tokens per parameter, which characterizes the degree of overtraining. Typically, a suite of Chinchilla scaling checkpoints contains checkpoints at either side of the typical 20 tokens per parameter recommendation derived from [^10]. However, since $T^{2}$ suggests overtraining beyond the available set of checkpoints, we train additional checkpoints at higher tokens per parameter ratios. The overtrained checkpoints (shown in orange) are used to validate our forecasts in §4.2.

![Refer to caption](https://arxiv.org/html/2604.01411v1/x6.png)

Figure 8: Overall checkpoint scaling grid. Each cell reports the number of tokens per parameter. Orange cells are overtrained checkpoints we created.

### C.2 Hyperparameters

We train our overtrained checkpoints, shown in Figure 8, from scratch using the OpenLM framework with same fixed hyperparameters used for the Chinchilla-optimal checkpoints from [^21]. Specifically, we use their hparams=base, warmup=short, decay=chinchilla configuration. We use the AdamW optimizer with a learning rate of $3\times 10^{-3}$, $\beta_{1}=0.9$, $\beta_{2}=0.95$, and a decoupled weight decay of $1\times 10^{-4}$. Training uses a global batch size of 256 sequences of length 2048 tokens, cosine learning rate decay to zero matched to the token budget of each run, and a warmup period equal in tokens to the model’s parameter count. We apply gradient clipping with a max norm of 1.0, QK-normalization, z-loss with coefficient $10^{-4}$, and train in bfloat16 mixed precision. All hyperparameters are held fixed across model sizes, consistent with the base (untuned) configuration of [^21]. We train on the RefinedWeb dataset with a vocabulary size of 50,432.

## Appendix D Post-Training Details

We describe our post-training setup and configurations below. We employ two variants of post-training: (i) standard fine-tuning and (ii) supervised fine-tuning (SFT). Standard fine-tuning follows the conventional next-token prediction objective, computing loss over both the instruction (question) and completion (answer). SFT, in contrast, computes loss over the completion only, excluding instruction tokens from parameter updates.

We fine-tune on three tasks—ARC Easy [^4], SciQ [^13], and OpenBookQA [^17] —covering the full population of pretrained checkpoints, including the overtrained ones. Each model is trained for 6 epochs until convergence using a batch size of 8 and a constant learning rate of $2\times 10^{-5}$, after that we evaluate on the respective test set. All fine-tuning experiments are conducted on 4 NVIDIA A10 GPUs. Box D presents the training data format for each task, where the highlighted tokens indicate the completion portion used in the SFT loss computation. Their evaluation follows the same format: we measure negative log-likelihood over the correct answer placed in the highlighted placeholder.

<svg id="A4.1.pic1" class="ltx_picture" height="783.52" overflow="visible" version="1.1" viewBox="0 0 600 783.52" width="600"><g style="--ltx-stroke-color:#000000;--ltx-fill-color:#000000;" transform="translate(0,783.52) matrix(1 0 0 -1 0 0)" fill="#000000" stroke="#000000" stroke-width="0.4pt"><g style="--ltx-fill-color:#BFBFBF;" fill="#BFBFBF" fill-opacity="1.0"><path style="stroke:none" d="M 0 5.91 L 0 777.62 C 0 780.88 2.64 783.52 5.91 783.52 L 594.09 783.52 C 597.36 783.52 600 780.88 600 777.62 L 600 5.91 C 600 2.64 597.36 0 594.09 0 L 5.91 0 C 2.64 0 0 2.64 0 5.91 Z"></path></g><g style="--ltx-fill-color:#F9F9F9;" fill="#F9F9F9" fill-opacity="1.0"><path style="stroke:none" d="M 1.97 5.91 L 1.97 759.41 L 598.03 759.41 L 598.03 5.91 C 598.03 3.73 596.27 1.97 594.09 1.97 L 5.91 1.97 C 3.73 1.97 1.97 3.73 1.97 5.91 Z"></path></g><g fill-opacity="1.0" transform="matrix(1.0 0.0 0.0 1.0 21.65 768.01)"><foreignObject style="--ltx-fg-color:#FFFFFF;--ltx-fo-width:40.23em;--ltx-fo-height:0.69em;--ltx-fo-depth:0.19em;" width="556.69" height="12.3" transform="matrix(1 0 0 -1 0 9.61)" overflow="visible" color="#FFFFFF">Box 1: Training Data Formats </foreignObject></g><g fill-opacity="1.0" transform="matrix(1.0 0.0 0.0 1.0 21.65 249.7)"><foreignObject style="--ltx-fg-color:#000000;--ltx-fo-width:40.23em;--ltx-fo-height:35.98em;--ltx-fo-depth:17.05em;" width="556.69" height="733.82" transform="matrix(1 0 0 -1 0 497.9)" overflow="visible" color="#000000">Each format separates the prompt (plain) from the completion (highlighted), which is the only portion used in the SFT loss. ARC Easy: <a href="data:text/plain;base64,UXVlc3Rpb246IHtxdWVzdGlvbn1cbkFuc3dlcjooKkBcY29sb3Jib3h7eWVsbG93ITQwfXtcdGV4dHR0eyBce2Fuc3dlclx9fX1AKik=">⬇</a> Question: {question}\nAnswer: {answer} OpenBookQA: <a href="data:text/plain;base64,e3F1ZXN0aW9ufSgqQFxjb2xvcmJveHt5ZWxsb3chNDB9e1x0ZXh0dHR7IFx7YW5zd2VyXH19fUAqKQ==">⬇</a> {question} {answer} SciQ: <a href="data:text/plain;base64,e3N1cHBvcnR9XG5RdWVzdGlvbjoge3F1ZXN0aW9ufVxuQW5zd2VyOigqQFxjb2xvcmJveHt5ZWxsb3chNDB9e1x0ZXh0dHR7IFx7YW5zd2VyXH19fUAqKQ==">⬇</a> {support}\nQuestion: {question}\nAnswer: {answer}</foreignObject></g></g></svg>

## Appendix E Evaluation Tasks

Next, we describe the eight downstream tasks used to evaluate $T^{2}$ scaling, covering both real-world benchmarks and synthetic tasks. For all tasks, we measure the NLL of each model over the correct answer.

We evaluate on four real-world benchmarks.

1. LAMBADA [^19] (OpenAI variant): tests long-range language understanding, where the model must predict the final word of a passage given a broad context.
2. ARC Easy [^4]: consists of elementary-level science questions in a four-way multiple choice format, drawn from standardized tests.
3. SciQ [^13]: contains science exam questions paired with supporting passages, presented in a multiple-choice format.
4. OpenBookQA [^17]: requires multi-step reasoning by combining an open book of core science facts with broader common knowledge, presented as four-way multiple choice questions.

In addition to these four benchmarks, we incorporate four synthetic tasks spanning different domains. These tasks are designed to evaluate models on (i) simple knowledge recall, (ii) multi-step arithmetic reasoning, (iii) commonsense causal reasoning, and (iv) spatial reasoning. Each task consists of 1,000 fill-in-the-blank or short-completion questions, generated using GPT-5 and Claude Opus 4.6. Below, we present representative examples from each task along with their evaluation format. As in Box D, the token spans used to compute the NLL are highlighted in each example below.

<svg id="A5.1.pic1" class="ltx_picture" height="1315.36" overflow="visible" version="1.1" viewBox="0 0 600 1315.36" width="600"><g style="--ltx-stroke-color:#000000;--ltx-fill-color:#000000;" transform="translate(0,1315.36) matrix(1 0 0 -1 0 0)" fill="#000000" stroke="#000000" stroke-width="0.4pt"><g style="--ltx-fill-color:#80FFFF;" fill="#80FFFF" fill-opacity="1.0"><path style="stroke:none" d="M 0 5.91 L 0 1309.46 C 0 1312.72 2.64 1315.36 5.91 1315.36 L 594.09 1315.36 C 597.36 1315.36 600 1312.72 600 1309.46 L 600 5.91 C 600 2.64 597.36 0 594.09 0 L 5.91 0 C 2.64 0 0 2.64 0 5.91 Z"></path></g><g style="--ltx-fill-color:#EBFFFF;" fill="#EBFFFF" fill-opacity="1.0"><path style="stroke:none" d="M 1.97 5.91 L 1.97 1291.25 L 598.03 1291.25 L 598.03 5.91 C 598.03 3.73 596.27 1.97 594.09 1.97 L 5.91 1.97 C 3.73 1.97 1.97 3.73 1.97 5.91 Z"></path></g><g fill-opacity="1.0" transform="matrix(1.0 0.0 0.0 1.0 21.65 1299.85)"><foreignObject style="--ltx-fg-color:#FFFFFF;--ltx-fo-width:40.23em;--ltx-fo-height:0.69em;--ltx-fo-depth:0.19em;" width="556.69" height="12.3" transform="matrix(1 0 0 -1 0 9.61)" overflow="visible" color="#FFFFFF">Box 2: Commonsense Causal Reasoning </foreignObject></g><g fill-opacity="1.0" transform="matrix(1.0 0.0 0.0 1.0 21.65 598.01)"><foreignObject style="--ltx-fg-color:#000000;--ltx-fo-width:40.23em;--ltx-fo-height:49.25em;--ltx-fo-depth:42.22em;" width="556.69" height="1265.66" transform="matrix(1 0 0 -1 0 681.43)" overflow="visible" color="#000000">Example 1: <a href="data:text/plain;base64,R3JhbmRwYXJlbnRzIHRlbGwgc3RvcmllcyB0byBncmFuZGNoaWxkcmVuLiBUZWFjaGVycyBleHBsYWluCmNvbmNlcHRzIHRvIHN0dWRlbnRzLiBDb2FjaGVzIGRlbW9uc3RyYXRlIHRlY2huaXF1ZXMgdG8oKkBcY29sb3Jib3h7eWVsbG93ITQwfXtcdGV4dHR0eyBwbGF5ZXJzfX1AKik=">⬇</a> Grandparents tell stories to grandchildren. Teachers explain concepts to students. Coaches demonstrate techniques to players Example 2: <a href="data:text/plain;base64,QSBtb3RoZXIgY29tZm9ydHMgYSBjcnlpbmcgYmFieS4gQSB0ZWFjaGVyIGVuY291cmFnZXMgYQpzdHJ1Z2dsaW5nIHN0dWRlbnQuIEEgY29hY2ggbW90aXZhdGVzIGEgZGlzY291cmFnZWQoKkBcY29sb3Jib3h7eWVsbG93ITQwfXtcdGV4dHR0eyBwbGF5ZXJ9fUAqKQ==">⬇</a> A mother comforts a crying baby. A teacher encourages a struggling student. A coach motivates a discouraged player</foreignObject></g></g></svg><svg id="A5.2.pic1" class="ltx_picture" height="545.41" overflow="visible" version="1.1" viewBox="0 0 600 545.41" width="600"><g style="--ltx-stroke-color:#000000;--ltx-fill-color:#000000;" transform="translate(0,545.41) matrix(1 0 0 -1 0 0)" fill="#000000" stroke="#000000" stroke-width="0.4pt"><g style="--ltx-fill-color:#80FFFF;" fill="#80FFFF" fill-opacity="1.0"><path style="stroke:none" d="M 0 5.91 L 0 539.51 C 0 542.77 2.64 545.41 5.91 545.41 L 594.09 545.41 C 597.36 545.41 600 542.77 600 539.51 L 600 5.91 C 600 2.64 597.36 0 594.09 0 L 5.91 0 C 2.64 0 0 2.64 0 5.91 Z"></path></g><g style="--ltx-fill-color:#EBFFFF;" fill="#EBFFFF" fill-opacity="1.0"><path style="stroke:none" d="M 1.97 5.91 L 1.97 521.3 L 598.03 521.3 L 598.03 5.91 C 598.03 3.73 596.27 1.97 594.09 1.97 L 5.91 1.97 C 3.73 1.97 1.97 3.73 1.97 5.91 Z"></path></g><g fill-opacity="1.0" transform="matrix(1.0 0.0 0.0 1.0 21.65 529.9)"><foreignObject style="--ltx-fg-color:#FFFFFF;--ltx-fo-width:40.23em;--ltx-fo-height:0.69em;--ltx-fo-depth:0.19em;" width="556.69" height="12.3" transform="matrix(1 0 0 -1 0 9.61)" overflow="visible" color="#FFFFFF">Box 3: Simple Knowledge Recall </foreignObject></g><g fill-opacity="1.0" transform="matrix(1.0 0.0 0.0 1.0 21.65 146.61)"><foreignObject style="--ltx-fg-color:#000000;--ltx-fo-width:40.23em;--ltx-fo-height:26.22em;--ltx-fo-depth:9.6em;" width="556.69" height="495.71" transform="matrix(1 0 0 -1 0 362.88)" overflow="visible" color="#000000">Example 1: <a href="data:text/plain;base64,VGhlIGNhcGl0YWwgb2YgRWd5cHQgaXMoKkBcY29sb3Jib3h7eWVsbG93ITQwfXtcdGV4dHR0eyBDYWlyb319QCop">⬇</a> The capital of Egypt is Cairo Example 2: <a href="data:text/plain;base64,VGhlIGZpZnRoIHRhc3RlIGlzKCpAXGNvbG9yYm94e3llbGxvdyE0MH17XHRleHR0dHsgdW1hbWl9fUAqKQ==">⬇</a> The fifth taste is umami</foreignObject></g></g></svg><svg id="A5.3.pic1" class="ltx_picture" height="1923.58" overflow="visible" version="1.1" viewBox="0 0 600 1923.58" width="600"><g style="--ltx-stroke-color:#000000;--ltx-fill-color:#000000;" transform="translate(0,1923.58) matrix(1 0 0 -1 0 0)" fill="#000000" stroke="#000000" stroke-width="0.4pt"><g style="--ltx-fill-color:#80FFFF;" fill="#80FFFF" fill-opacity="1.0"><path style="stroke:none" d="M 0 5.91 L 0 1917.67 C 0 1920.93 2.64 1923.58 5.91 1923.58 L 594.09 1923.58 C 597.36 1923.58 600 1920.93 600 1917.67 L 600 5.91 C 600 2.64 597.36 0 594.09 0 L 5.91 0 C 2.64 0 0 2.64 0 5.91 Z"></path></g><g style="--ltx-fill-color:#EBFFFF;" fill="#EBFFFF" fill-opacity="1.0"><path style="stroke:none" d="M 1.97 5.91 L 1.97 1899.47 L 598.03 1899.47 L 598.03 5.91 C 598.03 3.73 596.27 1.97 594.09 1.97 L 5.91 1.97 C 3.73 1.97 1.97 3.73 1.97 5.91 Z"></path></g><g fill-opacity="1.0" transform="matrix(1.0 0.0 0.0 1.0 21.65 1908.06)"><foreignObject style="--ltx-fg-color:#FFFFFF;--ltx-fo-width:40.23em;--ltx-fo-height:0.69em;--ltx-fo-depth:0.19em;" width="556.69" height="12.3" transform="matrix(1 0 0 -1 0 9.61)" overflow="visible" color="#FFFFFF">Box 4: Multi-Step Arithmetic Reasoning </foreignObject></g><g fill-opacity="1.0" transform="matrix(1.0 0.0 0.0 1.0 21.65 628.14)"><foreignObject style="--ltx-fg-color:#000000;--ltx-fo-width:40.23em;--ltx-fo-height:91.02em;--ltx-fo-depth:44.4em;" width="556.69" height="1873.88" transform="matrix(1 0 0 -1 0 1259.51)" overflow="visible" color="#000000">Example 1: <a href="data:text/plain;base64,SSBoYXZlIDUgdG95cy4gSSBnaXZlIGF3YXkgMiB0b3lzLiBTdGVwIDE6IEkgc3RhcnRlZCB3aXRoIDUKdG95cy4gU3RlcCAyOiBJIGdhdmUgYXdheSAyIHRveXMuIFN0ZXAgMzogNSBtaW51cyAyIGVxdWFscygqQFxjb2xvcmJveHt5ZWxsb3chNDB9e1x0ZXh0dHR7IDN9fUAqKQ==">⬇</a> I have 5 toys. I give away 2 toys. Step 1: I started with 5 toys. Step 2: I gave away 2 toys. Step 3: 5 minus 2 equals 3 Example 2: <a href="data:text/plain;base64,UGF0dGVybjogMTAsIDIwLCAzMCwgLi4uIFRoaXMgYWRkcyAxMCBlYWNoIHRpbWUuIEFmdGVyIDMwCmNvbWVzKCpAXGNvbG9yYm94e3llbGxvdyE0MH17XHRleHR0dHsgNDB9fUAqKQ==">⬇</a> Pattern: 10, 20, 30,... This adds 10 each time. After 30 comes 40</foreignObject></g></g></svg><svg id="A5.4.pic1" class="ltx_picture" height="1727.4" overflow="visible" version="1.1" viewBox="0 0 600 1727.4" width="600"><g style="--ltx-stroke-color:#000000;--ltx-fill-color:#000000;" transform="translate(0,1727.4) matrix(1 0 0 -1 0 0)" fill="#000000" stroke="#000000" stroke-width="0.4pt"><g style="--ltx-fill-color:#80FFFF;" fill="#80FFFF" fill-opacity="1.0"><path style="stroke:none" d="M 0 5.91 L 0 1721.49 C 0 1724.75 2.64 1727.4 5.91 1727.4 L 594.09 1727.4 C 597.36 1727.4 600 1724.75 600 1721.49 L 600 5.91 C 600 2.64 597.36 0 594.09 0 L 5.91 0 C 2.64 0 0 2.64 0 5.91 Z"></path></g><g style="--ltx-fill-color:#EBFFFF;" fill="#EBFFFF" fill-opacity="1.0"><path style="stroke:none" d="M 1.97 5.91 L 1.97 1703.29 L 598.03 1703.29 L 598.03 5.91 C 598.03 3.73 596.27 1.97 594.09 1.97 L 5.91 1.97 C 3.73 1.97 1.97 3.73 1.97 5.91 Z"></path></g><g fill-opacity="1.0" transform="matrix(1.0 0.0 0.0 1.0 21.65 1711.88)"><foreignObject style="--ltx-fg-color:#FFFFFF;--ltx-fo-width:40.23em;--ltx-fo-height:0.69em;--ltx-fo-depth:0.19em;" width="556.69" height="12.3" transform="matrix(1 0 0 -1 0 9.61)" overflow="visible" color="#FFFFFF">Box 5: Spatial Reasoning </foreignObject></g><g fill-opacity="1.0" transform="matrix(1.0 0.0 0.0 1.0 21.65 647.82)"><foreignObject style="--ltx-fg-color:#000000;--ltx-fo-width:40.23em;--ltx-fo-height:75.42em;--ltx-fo-depth:45.82em;" width="556.69" height="1677.7" transform="matrix(1 0 0 -1 0 1043.66)" overflow="visible" color="#000000">Example 1: <a href="data:text/plain;base64,VGhlIGJhYnkgaXMgaW4gdGhlIGNyaWIuIFRoZSBjcmliIGlzIGluIHRoZSBudXJzZXJ5LiBUaGUKbnVyc2VyeSBpcyBpbiB0aGUgaG91c2UuIFNvIHRoZSBiYWJ5IGlzIGluIHRoZSgqQFxjb2xvcmJveHt5ZWxsb3chNDB9e1x0ZXh0dHR7IGhvdXNlfX1AKik=">⬇</a> The baby is in the crib. The crib is in the nursery. The nursery is in the house. So the baby is in the house Example 2: <a href="data:text/plain;base64,VGhlIGdsYXNzZXMgYXJlIGluIHRoZSBjYXNlLiBUaGUgY2FzZSBpcyBpbiB0aGUgaGFuZGJhZy4KU28gdGhlIGdsYXNzZXMgYXJlIGluIHRoZSgqQFxjb2xvcmJveHt5ZWxsb3chNDB9e1x0ZXh0dHR7IGhhbmRiYWd9fUAqKQ==">⬇</a> The glasses are in the case. The case is in the handbag. So the glasses are in the handbag</foreignObject></g></g></svg>

## Appendix F Fitting T2T^{2} Scaling

In this section, we describe how each of our $T^{2}$ approaches are fit to empirical checkpoints.

#### Fitting Approach 1.

We fit the seven parameters $(\log A,\log B,\log E,\alpha,\beta,\log G,\gamma)$ of the additive model by minimizing the sum of squared errors (SSE) between predicted and empirical NLL values across all checkpoints and sampled values of $k$. We use the L-BFGS-B algorithm with 500 random restarts (each with up to 5,000 iterations and a tolerance of $10^{-15}$) and we select the run with the lowest objective value.

#### Fitting Approach 2.

We fit the model in two stages. First, we fit the standard Chinchilla scaling model $\widehat{L}(N,D)=E+\frac{A}{N^{\alpha}}+\frac{B}{D^{\beta}}$ to the empirical NLL values of all checkpoints. We profile over a grid of 40 candidate $E$ values spaced between $0.01\cdot\min(\text{NLL})$ and $0.95\cdot\min(\text{NLL})$; for each, we optimize the remaining four parameters $(\log A,\log B,\alpha,\beta)$ via L-BFGS-B with 50+ random restarts, using inverse-variance weighting across isoFLOP groups. Second, we fit the Beta regression parameters. The per-question success probability is modeled as $p\sim\text{Beta}(a_{N,D},b_{N,D})$ where $\mu=a_{N,D}/(a_{N,D}+b_{N,D})$ is a scaled logit link and the concentration $\nu=a_{N,D}+b_{N,D}$ is parameterized as a log link function. Together, the five parameters $(\theta_{0},\theta_{1},\theta_{2},\theta_{3},\theta_{4})$ are fit by minimizing SSE between predicted and empirical pass@ $k$ accuracy values over a grid of initializations seeded from a sigmoid baseline, again using L-BFGS-B.

[^1]: Establishing task scaling laws via compute-efficient model ladders. arXiv preprint arXiv:2412.04403. Cited by: §A.1.

[^2]: Large language monkeys: scaling inference compute with repeated sampling. External Links: [Link](https://openreview.net/forum?id=0xUEBQV54B) Cited by: §A.2, §1, §1, §3.1, §3.1.

[^3]: Evaluating large language models trained on code. arXiv preprint arXiv:2107.03374. Cited by: §3.1.

[^4]: Think you have solved question answering? try arc, the ai2 reasoning challenge. arXiv:1803.05457v1. Cited by: Appendix D, item 2, §4.

[^5]: Codemonkeys: scaling test-time compute for software engineering. arXiv preprint arXiv:2501.14723. Cited by: §3.1.

[^6]: Scaling laws for data filtering–data curation cannot be compute agnostic. In Proceedings of the IEEE/CVF Conference on Computer Vision and Pattern Recognition, pp. 22702–22711. Cited by: §A.1.

[^7]: The llama 3 herd of models. arXiv preprint arXiv:2407.21783. Cited by: §3.2.

[^8]: OLMo: accelerating the science of language models. In Proceedings of the 62nd Annual Meeting of the Association for Computational Linguistics (Volume 1: Long Papers), pp. 15789–15809. Cited by: §A.3, §1.

[^9]: Deepseek-r1: incentivizing reasoning capability in llms via reinforcement learning. arXiv preprint arXiv:2501.12948. Cited by: §1.

[^10]: Training compute-optimal large language models. arXiv preprint arXiv:2203.15556 10. Cited by: §A.1, §A.3, §C.1, §1, §1, §2, Figure 2, §4.1, §4.1.

[^11]: Scaling laws for downstream task performance of large language models. In ICLR 2024 Workshop on Mathematical and Empirical Understanding of Foundation Models, Cited by: §A.1.

[^12]: Openai o1 system card. arXiv preprint arXiv:2412.16720. Cited by: §A.2, §1.

[^13]: Crowdsourcing multiple choice science questions. Cited by: Appendix D, item 3, §4.

[^14]: Scaling laws for neural language models. arXiv preprint arXiv:2001.08361. Cited by: §A.1, §1.

[^15]: Efficient prediction of pass@ k scaling in large language models. arXiv preprint arXiv:2510.05197. Cited by: §3.2.

[^16]: Self-refine: iterative refinement with self-feedback. Advances in neural information processing systems 36, pp. 46534–46594. Cited by: §A.2.

[^17]: Can a suit of armor conduct electricity? a new dataset for open book question answering. In EMNLP, Cited by: Appendix D, item 4, §4.

[^18]: Reward models enable scalable code verification by trading accuracy for throughput. arXiv preprint arXiv:2506.10056. Cited by: §A.2.

[^19]: The lambada dataset. Zenodo. External Links: [Document](https://dx.doi.org/10.5281/zenodo.2630551) Cited by: item 1, §4.

[^20]: The refinedweb dataset for falcon LLM: outperforming curated corpora with web data only. In Thirty-seventh Conference on Neural Information Processing Systems Datasets and Benchmarks Track, External Links: [Link](https://openreview.net/forum?id=kM5eGcdCzq) Cited by: §4.

[^21]: Resolving discrepancies in compute-optimal scaling of language models. Advances in Neural Information Processing Systems 37, pp. 100535–100570. Cited by: §C.1, §C.2, §1, Figure 4, §4.2, §4.

[^22]: Qwen2. 5 technical report. arXiv preprint. Cited by: §1.

[^23]: Language models are unsupervised multitask learners. Cited by: §4.

[^24]: Compute optimal scaling of skills: knowledge vs reasoning. In Findings of the Association for Computational Linguistics: ACL 2025, pp. 13295–13316. Cited by: §A.1.

[^25]: Shrinking the generation-verification gap with weak verifiers. arXiv preprint arXiv:2506.18203. Cited by: §A.2.

[^26]: Beyond chinchilla-optimal: accounting for inference in language model scaling laws. In International Conference on Machine Learning, External Links: [Link](https://api.semanticscholar.org/CorpusID:266693796) Cited by: §A.1, §1.

[^27]: How do large language monkeys get their power (laws)?. In Forty-second International Conference on Machine Learning, External Links: [Link](https://openreview.net/forum?id=QqVZ28qems) Cited by: §3.1, §3.1.

[^28]: Pretraining scaling laws for generative evaluations of language models. In The Fourteenth International Conference on Learning Representations, External Links: [Link](https://openreview.net/forum?id=Ym33xJYINV) Cited by: §1.

[^29]: Scaling laws for native multimodal models. In Proceedings of the IEEE/CVF International Conference on Computer Vision, pp. 12–23. Cited by: §A.1.

[^30]: Scaling llm test-time compute optimally can be more effective than scaling model parameters. arXiv preprint arXiv:2408.03314. Cited by: §A.2, §1, §1, §4.1.

[^31]: Overtrained language models are harder to fine-tune. arXiv preprint arXiv:2503.19206. Cited by: §A.3, Figure 5, §4.3.

[^32]: Gemma 2: improving open language models at a practical size. arXiv preprint arXiv:2408.00118. Cited by: §A.3.

[^33]: Llama 2: open foundation and fine-tuned chat models. arXiv preprint arXiv:2307.09288. Cited by: §A.3, §1.

[^34]: Chain-of-thought prompting elicits reasoning in large language models. Advances in neural information processing systems 35, pp. 24824–24837. Cited by: §A.2.

[^35]: A survey on test-time scaling in large language models: what, how, where, and how well?. arXiv preprint arXiv:2503.24235. Cited by: §A.2.