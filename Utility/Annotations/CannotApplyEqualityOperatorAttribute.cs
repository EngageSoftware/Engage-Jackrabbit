// <copyright file="CannotApplyEqualityOperatorAttribute.cs" company="JetBrains s.r.o.">
// Copyright 2007-2012 JetBrains s.r.o.
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// </copyright>

namespace JetBrains.Annotations
{
    using System;

    /// <summary>Indicates that the value of the marked type (or its derivatives)
    /// cannot be compared using '==' or '!=' operators and <c>Equals()</c> should be used instead.
    /// However, using '==' or '!=' for comparison with <c>null</c> is always permitted.</summary>
    /// <example>
    ///   <code>
    /// [CannotApplyEqualityOperator]
    /// class NoEquality
    /// {
    /// }
    /// class UsesNoEquality
    /// {
    /// public void Test()
    /// {
    /// var ca1 = new NoEquality();
    /// var ca2 = new NoEquality();
    /// if (ca1 != null) // OK
    /// {
    /// bool condition = ca1 == ca2; // Warning
    /// }
    /// }
    /// }
    ///   </code>
    /// </example>
    [AttributeUsage(AttributeTargets.Interface | AttributeTargets.Class | AttributeTargets.Struct, AllowMultiple = false, Inherited = true)]
    public sealed class CannotApplyEqualityOperatorAttribute : Attribute
    {
    }
}