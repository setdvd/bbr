import { AxiosError, AxiosRequestConfig, AxiosResponse } from 'axios'
import axios from 'axios'


const axiosInstance = axios.create({
  baseURL: "https://api.bitbucket.org/2.0"
})


export type RequestConfig = AxiosRequestConfig

function getData(response: AxiosResponse) {
  return response.data
}

export type RequestCatchError = AxiosError | Error



export function getWithResponse<T>(
  url: string,
  config?: RequestConfig
): Promise<AxiosResponse<T>> {
  return axiosInstance.get<T>(url, config)
}

export function get<T>(url: string, config?: RequestConfig): Promise<T> {
  return axiosInstance.get<T>(url, config).then(getData)
}

export function post<T>(
  url: string,
  data?: any,
  config?: RequestConfig
): Promise<T> {
  return axiosInstance
    .post<T>(url, data, config)
    .then(getData)
}

export function put<T>(
  url: string,
  data?: any,
  config?: RequestConfig
): Promise<T> {
  return axiosInstance
    .put<T>(url, data, config)
    .then(getData)
}

export function patch<T>(
  url: string,
  data?: any,
  config?: RequestConfig
): Promise<T> {
  return axiosInstance
    .patch<T>(url, data, config)
    .then(getData)
}

export function remove<T>(url: string, config?: RequestConfig): Promise<T> {
  return axiosInstance.delete(url, config).then(getData)
}
