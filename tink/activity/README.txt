Example of ActivityIndicator using a Rotator in it's skin.

The ActivityIndicator is basically a facade to it's indicator skin part.

This is too keep the ActivityIndicator flexible, in that some people might want something to spin, others might want a horizontal animating barbershop bar, others might want a movie clip animation. The indicator skin part itself just need to implement IAnimator to be used.

The Rotator is a some skinnable component that rotates its skin around it's centre point when told to play. Anything can be used inside it's skin. You can change the amount of rotation applied on each frame by setting the delta property.

To have something look like the mobile BusyIndicator, in the past I have used a DataGroup, with an item renderer which is a simple thin Rect. I then use a custom CircularLayout for the DataGroup.

Tomasz's design features circles of different sizes. The above concept could be used, but use a standard itemRenderer with an Ellipse inside. The size of the Ellipse would be based on the index of the renderer.

I'll look at tidying up and committing the CircularLayout.

I also have some containers that work well with the ActivityIndicator which I will tidy up and add. They show the ActivityIndicator in a particular skin state which is where the autoAnimate property comes in useful.