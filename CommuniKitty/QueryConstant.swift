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
