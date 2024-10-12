# color-blind-simulator
a simple iOS app to demonstrate what the world looks like for people with color vision deficiencies

### Description
Color vision deficiency (CVD) is a common but under-recognized condition that results in decreased ability to discern colors. It is usually hereditary (though there are acquired forms). There are several types depending on which color sensing opsin is missing. CVD is quite common; ***up to*** 1 in 12 males (8%) and 1 in 200 females (0.5%) have CVD. The prevalence of CVD has significant implications for graphic and UX design, as a significant fraction of the audience may not understand your use of color.

### Inspiration
I was talking to my 7 yo about how different people percieve the world differently, and we started talking about color blindness. He understood conceptually, but asked me what it was like to experience the world with color blindness. I said I didn't really know, but thought we could find out together by making a simple iOS app. It turns out in addition to the pedagogical value this app is also useful to double check design choices, and make sure infographics or apps are CVD accessible.

### Implementation
#### Design
- Camera Feed: The app uses AVCaptureSession to capture video frames from the device’s camera in real-time.
- Core Image Filtering: The captured frames are processed using Core Image filters, specifically `CIColorMatrix`, to adjust the color channels based on the type of color blindness selected.
- User Interface: The app provides a segmented control for switching between different filters (Protanopia, Deuteranopia, Tritanopia, and normal vision). The processed video is displayed using a UIImageView.

### Filters
Protanopia (Red-Weakness): Red channel is reduced significantly, shifting color perception toward greens and blues.
Deuteranopia (Green-Weakness): Green channel is reduced, with stronger emphasis on reds and blues.
Tritanopia (Blue-Weakness): Blue channel is reduced, shifting perception to reds and greens.

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


### Requirements
- iOS 13.0 or later
- Xcode 12 or later
- Swift 5.0

#### Setup and Usage
1. Clone the repository and open the project in Xcode.
2. Build and run the project on an iOS device with a camera.
3. Use the toggle in the app to switch between different color blindness simulations.


### References
- icon created using [Ishihara Plate Generator](https://franciscouzo.github.io/ishihara/)
- 
