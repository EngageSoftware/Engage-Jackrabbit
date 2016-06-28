// <copyright file="Extensions.cs" company="Engage Software">
// Engage: Jackrabbit
// Copyright (c) 2004-2016
// by Engage Software ( http://www.engagesoftware.com )
// </copyright>
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
// TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
// CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
namespace Engage.Dnn.Jackrabbit
{
    using System;
    using System.Globalization;

    /// <summary>Utility extension methods</summary>
    public static class Extensions
    {
        /// <summary> Parses the value as an <typeparamref name="TEnum"/> <c>enum</c>, returning <c>null</c> if the parsing is not successful.</summary>
        /// <param name="this">The value to parse.</param>
        /// <returns>An <typeparamref name="TEnum"/> value, or <c>null</c>.</returns>
        public static TEnum? ParseNullableEnum<TEnum>(this string @this) where TEnum : struct
        {
            TEnum value;
            if (Enum.TryParse(@this, out value))
            {
                return value;
            }

            return null;
        }

        /// <summary> Parses the value as an <see cref="int"/>, returning <c>null</c> if the parsing is not successful.
        /// Uses <see cref="CultureInfo.InvariantCulture"/> and <see cref="NumberStyles.Integer"/>.</summary>
        /// <param name="this">The value to parse.</param>
        /// <returns>An <see cref="int" /> value, or <c>null</c>.</returns>
        public static int? ParseNullableInt32(this string @this)
        {
            return @this.ParseNullableInt32(CultureInfo.InvariantCulture);
        }

        /// <summary>Parses the value as an <see cref="int"/>, returning <c>null</c> if the parsing is not successful.
        /// Uses <see cref="NumberStyles.Integer"/>.</summary>
        /// <param name="this">The value to parse.</param>
        /// <param name="provider">The provider.</param>
        /// <returns>An <see cref="int" /> value, or <c>null</c>.</returns>
        public static int? ParseNullableInt32(this string @this, IFormatProvider provider)
        {
            return @this.ParseNullableInt32(NumberStyles.Integer, provider);
        }

        /// <summary>Parses the value as an <see cref="int"/>, returning <c>null</c> if the parsing is not successful.</summary>
        /// <param name="this">The value to parse.</param>
        /// <param name="style">The style.</param>
        /// <param name="provider">The provider.</param>
        /// <returns>An <see cref="int" /> value, or <c>null</c>.</returns>
        public static int? ParseNullableInt32(this string @this, NumberStyles style, IFormatProvider provider)
        {
            int result;
            return int.TryParse(@this, style, provider, out result) ? result : (int?)null;
        }

        /// <summary>Returns a <see cref="string" /> that represents this instance.</summary>
        /// <typeparam name="T">The type of the value</typeparam>
        /// <param name="this">The value to convert into a <see cref="string" />.</param>
        /// <param name="provider">The provider.</param>
        /// <returns>A <see cref="string" /> that represents this instance.</returns>
        [CLSCompliant(false)]
        public static string ToString<T>(this T? @this, IFormatProvider provider) where T : struct, IConvertible
        {
            return @this.HasValue ? @this.Value.ToString(provider) : string.Empty;
        }
    }
}