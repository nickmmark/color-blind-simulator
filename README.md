# color-blind-simulator
an iOS ann webapp to demonstrate what the world looks like for people with [color vision deficiencies](https://www.nei.nih.gov/learn-about-eye-health/eye-conditions-and-diseases/color-blindness#:~:text=What%20is%20color%20blindness%3F,vision%20deficiency%20runs%20in%20families.)

Colored pencils            |  Ishihara vision test    |   Fall Foliage
:-------------------------:|:------------------------:|:-------------------------:
 <img src="https://github.com/nickmmark/color-blind-simulator/blob/main/Figures/Colored_Pencils.GIF" width="125"> | <img src="https://github.com/nickmmark/color-blind-simulator/blob/main/Figures/Ishihara_Color_test.GIF" width="125"> | <img src="https://github.com/nickmmark/color-blind-simulator/blob/main/Figures/Fall_foliage.GIF" width="550"> |

### Inspiration
I was talking to my 7 yo about how different people percieve the world differently, and we discussed color blindness. He understood conceptually, but asked me what _does it feel like_ to experience the world with color blindness. I said I didn't really know, but thought we could find out together by making a simple app. It turns out in addition to the pedagogical value this app is also useful to double check design choices, and ensure that infographics, websites, powerpoints, etc are accessible for everyone.

### Background
Humans are [trichromats](https://en.wikipedia.org/wiki/Trichromacy) meaning that we use 3 color sensing cones to perceive different wavelengths of light. We perceive color as the relative intensity of three different wavelengths.
- **L cones** - sensitive to longer wavelength light; peak sensitivity 560 nm (_red_)
- **M cones** - sensitive to medium wavelength light; peak sensitivity 530 nm (_yellow/green_)
- **S cones** - sensitive to short wavelength light; peak sensitivity 420 nm (_blue_)

![Plot of wavelength of light versus responsivity of human cone and rod cells](https://github.com/nickmmark/color-blind-simulator/blob/main/Figures/Cone_wavelengths_and_perception.jpg)

Absence of one or more of these cones alters our perception of color and causes **color vision deficiency** (CVD) as shown above. **Color vision deficiency** (CVD) is a common but under-recognized condition that results in decreased ability to discern colors. It is usually hereditary (though there are acquired forms) caused by a genetic defect in one of the three opsin genes. There are several types of CVD depending on which color sensing opsin is missing, though all are on the X-chromosome, and are thus more common in males.

CVD is quite common; ***up to*** 1 in 12 males (8%) and 1 in 200 females (0.5%) have CVD. The prevalence of CVD has significant implications for graphic and UX design, as a significant fraction of your audience may not perceive color as you do.

## IOS Implementation (Swift)
#### Design
- **Camera Feed**: The app uses `AVCaptureSession` to capture video frames from the device’s camera in real-time.
- **Core Image Filtering**: The captured frames are processed using Core Image filters, specifically `CIColorMatrix`, to adjust the color channels based on the type of color blindness selected.
- **User Interface**: The app provides a segmented control for switching between different filters (Protanopia, Deuteranopia, Tritanopia, and normal vision). The processed video is displayed using a `UIImageView`. The app also features `pinch-to-zoom` functionality and disables the `isIdleTimer` to prevent the screen from dimming.

### Filters
- **Protanopia** (Red-Weakness): Red channel is reduced significantly, shifting color perception toward greens and blues. (1% of males, 0.01% of females)
- **Deuteranopia** (Green-Weakness): Green channel is reduced, with stronger emphasis on reds and blues. (1.5% of males, 0.01% of females)
- **Tritanopia** (Blue-Weakness): Blue channel is reduced, shifting perception to reds and greens. (0.008% of males & females)

`CIColorMatrix` works by applying a color transformation matrix to an image. Each color channel (Red, Green, Blue, and Alpha) is multiplied by a vector that defines how much of each channel is used. In the app, the key property that we modify is:
- inputRVector: Controls the red channel.
- inputGVector: Controls the green channel.
- inputBVector: Controls the blue channel.
- inputAVector: Controls the alpha channel (transparency).
Each vector has four components (x, y, z, w) representing how much red, green, blue, and alpha contribute to the output of each respective channel.

For example, the vector for the red channel (inputRVector) looks like this:
```swift
CIVector(x: 0.567, y: 0.433, z: 0, w: 0)
```
This means:
0.567: Amount of red contributing to the red channel.
0.433: Amount of green contributing to the red channel.
0: Amount of blue contributing to the red channel.
0: Alpha channel is not affected.

#### Protanopia (Red-Weakness)
Protanopia affects the red cones in the eye, making it difficult to distinguish between reds and greens. To simulate this, we reduce the contribution of red to the image and emphasize green and blue.
```swift
// Protanopia filter matrix
filter.setValue(CIVector(x: 0.567, y: 0.433, z: 0, w: 0), forKey: "inputRVector") // Red channel reduced
filter.setValue(CIVector(x: 0.558, y: 0.442, z: 0, w: 0), forKey: "inputGVector")  // Keep green
filter.setValue(CIVector(x: 0, y: 0.242, z: 0.758, w: 0), forKey: "inputBVector")  // Boost blue

```

#### Tritanopia (Blue-Weakness)
Tritanopia affects the blue cones in the eye, causing difficulty in distinguishing between blues and greens. We reduce the contribution of the blue channel to simulate this.

```swift
// Tritanopia filter matrix
filter.setValue(CIVector(x: 0.95, y: 0.05, z: 0, w: 0), forKey: "inputRVector")    // Mostly red
filter.setValue(CIVector(x: 0, y: 0.433, z: 0.567, w: 0), forKey: "inputGVector")  // Green with blue
filter.setValue(CIVector(x: 0, y: 0.475, z: 0.525, w: 0), forKey: "inputBVector")  // Reduce blue
```

#### Adjusting the filters
To tweak the filters, you can modify the values in the CIVector for each channel:
- Boosting a color: Increase the value for that color in its corresponding vector (e.g., increase the first value in inputRVector to boost red).
- Reducing a color: Decrease the value for that color in its corresponding vector (e.g., decrease the first value in inputBVector to reduce blue).
- Each vector has values between 0.0 and 1.0, and you can play around with the numbers to fine-tune the color perception based on your needs.

Let’s say you want a stronger blue-weakness simulation for Tritanopia. You could change the blue vector (inputBVector) to:
```swift
CIVector(x: 0, y: 0.5, z: 0.5, w: 0)
```
This reduces the blue even more, further altering how blues are perceived in the image.


### Requirements
- iOS 13.0 or later
- Xcode 12 or later
- Swift 5.0

#### Setup and Usage
1. Clone the repository and open the project in Xcode.
2. Build and run the project on an iOS device with a camera.
3. Use the toggle in the app to switch between different color blindness simulations.

### Features to add... someday
[ ] I'd love to have this app function as a widget on the lock screen (e.g. you could more quickly open it)
[ ] It would be interesting if the app could display a broader range of colors to represent tetrachromacy (need to figure out how to represent this)

## WebApp Implementation (JS)

Demo [here](https://nickmmark.github.io/color-blind-simulator/web-app-color-blind-simulator/index.html)

### Features

* Live webcam via `getUserMedia
* Vision modes (human CVD): protan/deutan/tritan (-opia/-anomaly) + achromatopsia
* Animal modes: dog, deer, cat (dichromats) and pigeon, hawk (tetrachromats w/ UV false-color)
* Split view: left = original, right = simulated (aspect-correct “cover” draw; no distortion)
* Spectral chart: shows relative cone sensitivities (S/M/L; plus UV for birds) with optional human overlay
* Performance controls: processing scale slider, resolution picker, mirror toggle
* Snapshot: one-click PNG export of the simulated frame
* All local: no servers, no tracking, runs entirely in the browser

### How it works
* Per-pixel transform: Each frame is drawn to an offscreen canvas, transformed, then composited.
* Human CVD modes use established 3×3 matrices.
* Animal modes use explicit 3×3 matrices tuned to approximate known dichromat/tetrachromat percepts:
 * Dogs/deer/cats ≈ deuteranopia-like red–green compression with small hue shifts.
 * Pigeon/hawk add a mild blue/magenta lift to hint at UV (since displays can’t emit UV).
* Split view: Two independent “cover” draws crop the source to avoid stretch/compression in either half.
* Spectral plot: Gaussian cone models render S/M/L (and UV for tetrachromats) under a muted wavelength band; optional dashed overlay shows human for comparison.


## References
- icon created using [Ishihara Plate Generator](https://franciscouzo.github.io/ishihara/)
- conceptually this work is the opposite of the work by Elrefaei et al [Smartphone Based Image Color Correction for Color Blindness
Authors](https://online-journals.org/index.php/i-jim/article/view/8160)

