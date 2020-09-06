//
//  QueryConstant.swift
//  CommuniKitty
//
//  Created by shubham Garg on 16/08/20.
//  Copyright © 2020 White Rabbit Apps. All rights reserved.
//

import Foundation


let LOGIN = """
mutation loginUser($email: String!, $password: String!) {
  signIn(email: $email, password: $password) {
    user {
      id
      role
      fullName
      avatarUrl
      slug
      __typename
    }
    credential {
      authorization
      tokentype
      client
      expiry
      uid
      __typename
    }
    __typename
  }
}
"""

let SIGNUP = """
mutation signUpUser($firstName: String!, $lastName: String!, $email: String!, $password: String!, $passwordConfirmation: String!) {
  register(firstName: $firstName, lastName: $lastName, email: $email, password: $password, passwordConfirmation: $passwordConfirmation) {
    user {
      id
      role
      fullName
      avatarUrl
      slug
      __typename
    }
    credential {
      authorization
      tokentype
      client
      expiry
      uid
      __typename
    }
    __typename
  }
}
"""
let RESENDCONFIRMATION = """
"mutation resendConfirmation($email: String!) {
  resendConfirmation(email: $email) {
    message
    __typename
  }
}
"""

let GETCURRENTUSER = """
query getCurrentUser {
  currentUser {
    id
    role
    fullName
    avatarUrl
    slug
    __typename
  }
}
"""

let FORGETPASSWORD = """
mutation forgotPassword($email: String!) {
  forgotEmail(email: $email) {
    message
    __typename
  }
}
"""

let GETANIMALS = """
query getAnimals {
 records: animals {
    id
  avatarUrl
  age
  birthDate
  gender
  followersCount
  isFollowed
  facebookPageName
  instagramUsername
    name
    thumbnailUrl
    slug
  twitterUsername
    __typename
  }
}
"""

let GETBREADS = """
query getBreeds {
 records: breeds {
    id
    slug
    name
    thumbnailUrl
    __typename
  }
}
"""

let GETLOCATIONS = """
query getLocations($service: String, $page: Int, $perPage: Int) {
 data: locations(service: $service, page: $page, perPage: $perPage) {
    count
    page
    perPage
    records {
      id
      slug
      address
        phone
        yelpBusinessId
        facebookPageId
        twitterId
        instagramUsername
        pinterestId
        website
        geo
        åågooglePlaceId
      name
      logoUrl
      logoThumbnailUrl
      __typename
    }
    __typename
  }
}
"""


let LOGOUT = """
mutation logoutUser($userId: String!) {
  signOut(userId: $userId) {
    message
    __typename
  }
}
"""

let GETCURRENTANIMAL = """
query getCurrentAnimals {
 records: currentAnimals {
      id
    avatarUrl
    age
    birthDate
    gender
    followersCount
    isFollowed
    facebookPageName
    instagramUsername
      name
      thumbnailUrl
      slug
    twitterUsername
      __typename
  }
}
"""


let GETANIMALDETAIL = """
query getAnimal($slug: String!) {
  animal(slug: $slug) {
    id
    name
    intro
    slug
    username
    gender
    hairLength
    traitIds
    colors {
      id
      name
      __typename
    }
    microchipId
    facebookUrl
    facebookPageName
    twitterUrl
    twitterUsername
    instagramUrl
    instagramUsername
    youtubeUrl
    youtubeUsername
    tiktokUrl
    tiktokUsername
    donateMoneyLink
    donateSuppliesLink
    birthDate
    age
    loves {
      id
      text
      __typename
    }
    hates {
      id
      text
      __typename
    }
    photos {
      id
      thumbnailUrl
      photoUrl
      mediumPhotoUrl
      circularPhotoUrl
      sort
      __typename
    }
    owners {
      id
      role
      fullName
      avatarUrl
      slug
      __typename
    }
    fosters {
      id
      role
      fullName
      avatarUrl
      slug
      __typename
    }
    traits {
      name
      image
      __typename
    }
    breed {
      id
      name
      slug
      __typename
    }
    coat {
      id
      name
      imageUrl
      __typename
    }
    weightMeasurements {
      id
      takenAt
      display
      value
      unit
      __typename
    }
    lengthMeasurements {
      id
      takenAt
      display
      value
      unit
      __typename
    }
    city {
      id
      name
      state
      country
      centerLat
      centerLng
      __typename
    }
    location {
      id
      name
      slug
      logoUrl
      __typename
    }
    isFollowed
    followersCount
    avatarUrl
    __typename
  }
}
"""

let GETANIMALTIMELINE = """
query getAnimalStories($animalSlug: String!) {
  animalStories(animalSlug: $animalSlug) {
    id
    title
    thumbnailUrl
    date
    body
    event
    editable
    photos {
      id
      mediaType
      thumbnailUrl
      photoUrl
      mediumPhotoUrl
      largeUrl
      __typename
    }
    documents {
      id
      documentUrl
      __typename
    }
    medicalProcedure {
      id
      name
      description
      __typename
    }
    externalResourceUrl
    tags {
      id
      animalId
      __typename
    }
    __typename
  }
  animalHealthStories(animalSlug: $animalSlug) {
    id
    title
    thumbnailUrl
    date
    body
    event
    photos {
      id
      mediaType
      thumbnailUrl
      photoUrl
      mediumPhotoUrl
      largeUrl
      __typename
    }
    documents {
      id
      documentUrl
      __typename
    }
    medicalProcedure {
      id
      name
      description
      __typename
    }
    externalResourceUrl
    tags {
      id
      animalId
      __typename
    }
    __typename
  }
}
"""
