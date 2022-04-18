---
layout: default

---

# Running Example in Another File!

*Have you noticed how there is not trace of JS code whatsoever?*

## Ostrogradsky's Theorem

We recall the theorem first:
{% eqn %}
\iiint_V \nabla \cdot \vec v \dd{V} = \oiint_S \vec v \cdot \vec n \dd{S}
{% endeqn %}

### Preliminaries

To simplify, we only consider Riemann-sum type of integrals. This means in
particular that we only need to prove the theorem on any *n*-dimension
rectangular parallelepiped.

We also provide a proof for 3 dimensions only, but the proof can easily be
extended to *n* dimensions.

A rectangular parallelepiped (or *brick*) is defined by giving six numbers,
which are the bounds of the brick for each axis:
{% eqn %}
V = [a_1;a_2]\times [b_1;b_2]\times [c_1;c_2] = \left\{ (x,y,z) \mid a_1 \leq x \leq a_2, b_1 \leq y \leq b_2, c_1 \leq z \leq c_2 \right\}
{% endeqn %}

The surface associated to that brick is such that
{% eqn %}
S = A_{x,1} \cup A_{x,2} \cup A_{y,1} \cup A_{y,2} \cup A_{z,1} \cup A_{z,2}
{% endeqn %}

Where {% ieqn A_{a,i} %} is the left (1)/right (2) side of the brick following 
axis *a*.

Since {% ieqn \vec v %} is taken in {% ieqn \mathbb{R}^3 %}, we can decompose it 
on that space's canonical base:
{% eqn %}
\vec v = v_x \vec i + v_y \vec j + v_z \vec k
{% endeqn %}


### Proof

Let us unfold the left-hand side of the theorem:
{% eqn %}
\begin{split}
\iiint_V \nabla \cdot \vec v \dd{V} &= \iiint_V \left(\frac{\partial v_x}{\partial x} + \frac{\partial v_y}{\partial y} + \frac{\partial v_z}{\partial z} \right) \dd{x} \dd{y} \dd{z} \\
& = \iiint_V \frac{\partial v_x}{\partial x} \dd{x} \dd{y} \dd{z} + \iiint_V \frac{\partial v_y}{\partial y} \dd{x} \dd{y} \dd{z} + \iiint_V \frac{\partial v_z}{\partial z} \dd{x} \dd{y} \dd{z} \\
& = \int_{c_1}^{c_2} \int_{b_1}^{b_2} (v_x(a_2,y,z) - v_x(a_1,y,z)) \dd{y} \dd{z} + \ldots \\
& = \iint_{A_{x,2}} v_x \dd{y} \dd{z} - \iint_{A_{x,1}} v_x \dd{y} \dd{z} + \ldots
\end{split}
{% endeqn %}

Let's take a look at {% ieqn \vec n %}, the normal to *S*. Since the brick is
aligned on the axes, it turns out that:
{% eqn %}
\begin{split}
\vec n &= (-1,0,0) \quad\text{on}\:A_{x,1} \\
\vec n &= (+1,0,0) \quad\text{on}\:A_{x,2} \\
\vec n &= (0,-1,0) \quad\text{on}\:A_{y,1} \\
\vec n &= (0,+1,0) \quad\text{on}\:A_{y,2} \\
\vec n &= (0,0,-1) \quad\text{on}\:A_{z,1} \\
\vec n &= (0,0,+1) \quad\text{on}\:A_{z,2} 
\end{split}
{% endeqn %}

Let's calculate the inner product {% ieqn \vec v \cdot \vec n %} on each
surface:
{% eqn %}
\begin{split}
\vec v \cdot \vec n &= -v_x \quad\text{on}\:A_{x,1} \\
\vec v \cdot \vec n &= +v_x \quad\text{on}\:A_{x,2} \\
\vec v \cdot \vec n &= -v_y \quad\text{on}\:A_{y,1} \\
\vec v \cdot \vec n &= +v_y \quad\text{on}\:A_{y,2} \\
\vec v \cdot \vec n &= -v_z \quad\text{on}\:A_{z,1} \\
\vec v \cdot \vec n &= +v_z \quad\text{on}\:A_{z,2} 
\end{split}
{% endeqn %}

Also, each side is a flat square aligned on the basis, so the area element dS is
a square element following two axes,
i.e. {% ieqn \dd{S} = \dd{y} \dd{z} %} on {% ieqn A_{x,i} %}, and similarly for
each side.

Subsequently:
{% eqn %}
\iint_{A_{x,2}} \vec v \cdot \vec n \dd{S} = \iint_{A_{x,2}} v_x \dd{y} \dd{z}
{% endeqn %}

And similarly for each side. Summing up (pun intended):
{% eqn %}
\sum_{a \in \{x,y,z\}} \sum_{i=1,2} \iint_{A_{a,i}} \vec v \cdot \vec n \dd{S} = \iint_{A_{x,2}} v_x \dd{y} \dd{z} - \iint_{A_{x,1}} v_x \dd{y} \dd{z} + \ldots
{% endeqn %}

The left-hand side is a decomposition of the integration on the surface of *V*,
so we can rewrite it as {% ieqn \iint_S \vec v \cdot \vec n \dd{S} %}, and the
right-hand side corresponds to what we obtained at the end of the first step.
This brings us to:
{% eqn %}
\iiint_V \nabla \cdot \vec v \dd{V} = \iint_S \vec v \cdot \vec n \dd{S}
{% endeqn %}

And the proof is done!


# SO INCREDIBLLLLLLLLE!!!

One good thing about block equations is that they are wrapped in a display math
LaTeX environment, which means you can use cool environment such as `split` to
typeset your long equations or equality chains, as in the per-case normal
calculation above:
```latex
\begin{split}
\vec n &= (-1,0,0) \quad\text{on}\:A_{x,1} \\
\vec n &= (+1,0,0) \quad\text{on}\:A_{x,2} \\
\vec n &= (0,-1,0) \quad\text{on}\:A_{y,1} \\
\vec n &= (0,+1,0) \quad\text{on}\:A_{y,2} \\
\vec n &= (0,0,-1) \quad\text{on}\:A_{z,1} \\
\vec n &= (0,0,+1) \quad\text{on}\:A_{z,2} 
\end{split}
```








