//
//  CharacterDetailView.swift
//  Rick
//
//  Created by Ludvig Hemma on 2025-03-31.
//

import SwiftUI

struct CharacterDetailView: View {

  let character: Character

  @State private var backgroundColor = Color(UIColor.systemBackground)
  @State private var statsExpanded = true
  @State private var episodesExpanded = false

  var body: some View {

    ZStack {
      backgroundColor
        .ignoresSafeArea()
      ScrollView {
        LazyVStack(alignment: .leading) {
          AsyncImage(url: character.image) { image in
            image
              .resizable()
              .frame(maxWidth: .infinity)
              .aspectRatio(contentMode: .fit)

          } placeholder: {
            Image(systemName: "photo")
              .resizable()
              .frame(maxWidth: .infinity)
              .aspectRatio(contentMode: .fit)
              .foregroundStyle(Color(UIColor.systemGray))
          }
          Text(character.name)
            .font(.largeTitle)
            .fontWeight(.heavy)
            .padding(.horizontal)
          Text("Status: \(character.status)")
            .font(.subheadline)
            .padding(.horizontal)
            .background(character.statusColor.mix(with: backgroundColor, by: 0.4))
            .clipShape(.capsule)
            .padding(.horizontal)

          DisclosureGroup("Stats", isExpanded: $statsExpanded) {
            HStack {
              VStack(alignment: .leading) {
                Text("Species: \(character.species)")
                  .font(.title2)
                  .fontWeight(.thin)
                Text("Type: \(character.type)")
                  .font(.title2)
                  .fontWeight(.thin)
                Text("Gender: \(character.gender)")
                  .font(.title2)
                  .fontWeight(.thin)
              }
              .padding(.bottom)
              Spacer()
            }
          }
          .padding(.horizontal)
          .background(statsExpanded ? backgroundColor.mix(with: .black, by: 0.2) : .clear)
          .clipShape(.rect(cornerRadii: RectangleCornerRadii(topLeading: 10, bottomTrailing: 10)))
          .padding(.horizontal)
          DisclosureGroup("Episodes", isExpanded: $episodesExpanded) {
            ForEach(character.episode, id: \.self) { value in
              Text(value.absoluteString)
                .fontWeight(.thin)
            }
          }
          .padding(.horizontal)
          .background(episodesExpanded ? backgroundColor.mix(with: .black, by: 0.2) : .clear)
          .clipShape(.rect(cornerRadii: RectangleCornerRadii(topLeading: 10, bottomTrailing: 10)))
          .padding(.horizontal)
          Spacer()
        }
      }
    }
    .foregroundStyle(.black)
    .task {
      guard let (data, _) = try? await URLSession.shared.data(from: character.image),
            let uiImage = UIImage(data: data),
            let averageColor = uiImage.averageColor else {
        return
      }
      backgroundColor = Color(averageColor)
    }
  }
}

private extension Character {
  var statusColor: Color {
    if status == "Alive" {
      .green
    } else if status == "Dead" {
      .red
    } else {
      .brown
    }
  }
}

extension UIImage {
  /// Experimental code from
  /// https://www.hackingwithswift.com/example-code/media/how-to-read-the-average-color-of-a-uiimage-using-ciareaaverage
  var averageColor: UIColor? {
    guard let inputImage = CIImage(image: self) else { return nil }
    let extentVector = CIVector(x: inputImage.extent.origin.x,
                                y: inputImage.extent.origin.y,
                                z: inputImage.extent.size.width,
                                w: inputImage.extent.size.height)
    guard let filter = CIFilter(name: "CIAreaAverage",
                                parameters: [kCIInputImageKey: inputImage,
                                            kCIInputExtentKey: extentVector]) else { return nil }
    guard let outputImage = filter.outputImage else { return nil }
    var bitmap = [UInt8](repeating: 0, count: 4)
    CIContext(options: [.workingColorSpace: kCFNull!])
      .render(outputImage,
              toBitmap: &bitmap,
              rowBytes: 4,
              bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
              format: .RGBA8,
              colorSpace: nil)
    return UIColor(red: CGFloat(bitmap[0]) / 255,
                   green: CGFloat(bitmap[1]) / 255,
                   blue: CGFloat(bitmap[2]) / 255,
                   alpha: CGFloat(bitmap[3]) / 255)
  }
}


#Preview {
  CharacterDetailView(character: Character.sampleCharacter)
}
